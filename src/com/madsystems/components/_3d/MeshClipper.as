package com.madsystems.components._3d
{
	import math.Plane;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class MeshClipper
	{
		public var vertices:Vector.<Vector3D> ;
		public var triangles:Vector.<Triangle> ;
		public var edges:Vector.<Edge> ;
		public var planes:Vector.<Plane> ;
		public var uv:Vector.<Number> ;
		private var distances:Array = new Array();

		//	Keep a map of the split edges
		public var edgeMap:Dictionary = new Dictionary();
		
		public function MeshClipper( vertex:Vector.<Vector3D>, 
									 edges:Vector.<Edge>, 
									 triangles:Vector.<Triangle>, 
									 planes:Vector.<Plane>,
									 uv:Vector.<Point> )
		{
			//	Copy the vertices
			this.vertices = new Vector.<Vector3D>();
			for each ( var v:Vector3D in vertex )
				this.vertices.push( v.clone());
					
			//	Copy the edges
			this.edges = new Vector.<Edge>();
			for each ( var e:Edge in edges )
				this.edges.push( e.clone());
				
			//	Copy the trianges
			this.triangles = new Vector.<Triangle>();
			for each ( var t:Triangle in triangles )
				this.triangles.push( t.clone());
				
			//	Copy the texture coordinates
			this.uv = new Vector.<Number>();
			for each ( var n:Number in uv )
				this.uv.push( n);
			
			//	Keep a reference to the planes
			this.planes = planes ;

			//	Go through each plane and clip each vertex
			//	Note, the planes should have been transformed to world coordinates first
			for each ( var plane:Plane in planes ) {
				//	Empty the distances array
				while ( distances.length )
						distances.pop();
				
				//	Clip the vertices against the plane
				clipVerticies( plane );
				
				//	Clip the edges
				clipEdges();
				
				//	Clip the triangles
				clipTriangles();
			}
			
			//	Clean out the negative triangles
			var vertexMap:Object = new Object();
			var edgeMap:Object = new Object();
			var culledVertices:Vector.<Vector3D> = new Vector.<Vector3D>() ;
			var culledEdges:Vector.<Edge> = new Vector.<Edge>() ;
			var culledTriangles:Vector.<Triangle> = new Vector.<Triangle>() ;
			var culledUV:Vector.<Number> = new Vector.<Number>() ;
			var vertex:Vector3D ;
			var edge:Edge ;
			var triangle:Triangle ;
			
			//	First cull the vertices
			for ( var i:int = 0; i < vertices.length; i++ ) {
				vertex = vertices[ i ];
				if ( vertex.visible ) 
					vertexMap[ i ] = culledVertices.push( vertex )-1;
			}
			
			//	Then cull the edges
			for ( i = 0; i < edges.length; i++ ) {
				edge = edges[ i ];
				if ( edge.visible ) {
					edgeMap[ i ] = culledEdges.push( triangle )-1;
					edge.index[0] = int( vertexMap[ edge.index[0]] );
					edge.index[1] = int( vertexMap[ edge.index[1]] );
				}
			}
			
			//	Then cull the triangles
			for ( i = 0; i < triangles.length; i++ ) {
				triangle = triangles[ i ];
				if ( triangle.visible ) {
					map[ i ] = culledTriangles.push( triangle )-1;
					culledUV.push( uv[ i * 2 ] );
					culledUV.push( uv[ i * 2 + 1 ] );
					triangle.edges[0] = int( edgeMap[ triangle.edges[0]] ); 
					triangle.edges[1] = int( edgeMap[ triangle.edges[1]] ); 
					triangle.edges[2] = int( edgeMap[ triangle.edges[2]] ); 
				}
			}
		}
		
		private function clipVertices( plane:Plane ):void {
			for each ( var v:Vector3D in vertex ) 
				distances.push( plane.distanceTo( v ) );
		}
		private function clipEdges():void {
			
			//	Edge pointer
			var edge:Edge ;
			
			//	Intersection point plane parameters
			var s:Number ;
			var t:Number ;
			
			//	Vertex pointers
			var p:Vector3D, q:Vector3D, v:Vector3D, d:Vector3D ;
			
			//	New edge index
			var index:int ;
			
			//	The length of the current triangles array
			//	This is important, because we're throwing new triangles
			//	on to the end of the list.  Actually, I could probably
			//	directly reference the length parameter in the loop since
			//	we're not changing the triangle list in this function,
			//	but this is faster
			var n:int = triangles.length ;
			var value:Number ;
			
			//	Triangle vertex pointers
			var v0:int, v1:int, v2:int ;
			
			//	Texture coordinate pointers
			var u0:Number, u1:Number, u2:Number ;			
			var v0:Number, v1:Number, v2:Number ;			

			
			//	Loop over all the triangles
			for each ( var i:int = 0; i < n; i++ ) {
				
				//	Grab a triangle
				var triangle:Triangle = triangles[i] ;
				if ( !triangle.visible )
					continue ;
				
				//	Grab the distances
				var sDist0:Number = distances[triangle.index[0]];
				var sDist1:Number = distances[triangle.index[1]];
				var sDist2:Number = distances[triangle.index[2]];

				//	If the vertices are all positive, continue
				if ( sDist0 > 0 && sDist1 > 0 && sDist2 > 0 )
					continue ;
				
				//	If the vertices are all negative, turn off the triangle
				//	and continue
				if ( sDist0 < 0 && sDist1 < 0 && sDist2 < 0 ) {
					triangle.visible = false ;
					continue ;
				}

				//	Grab the vertex indices
				v0 = triangle.index[0] ;
				v1 = triangle.index[1] ;
				v2 = triangle.index[2] ;
								
				
				//	Grab the texture coordinates
				u0 = uv[ v0 * 2 ];
				v0 = uv[ v0 * 2 + 1 ];
				u1 = uv[ v1 * 2 ];
				v1 = uv[ v1 * 2 + 1 ];
				u2 = uv[ v2 * 2 ];
				v2 = uv[ v2 * 2 + 1 ];


				// The change-in-sign tests are structured this way to avoid numerical
				// round-off problems.  For example, sDist0 > 0 and sDist1 < 0, but
				// both are very small and sDist0*sDist1 = 0 due to round-off
				// errors.  The tests also guarantee consistency between this function
				// and ClassifyTriangles, the latter function using sign tests only on
				// the individual sDist values.
				
				//	Process an intersection on the first edge
				if ((sDist0 > 0 && sDist1 < 0)
					||  (sDist0 < 0 && sDist1 > 0))
				{
					//	Grab the edge we're about split
					edge = edges[ triangle.edges[0]] ;
					value = edge.valueOf();
					if (!edgeMap[value])
					{
						//	Turn the edge off because we split it
						edge.visible = false ;
						
						//	Calculate the value of the line parameter
						//	at the point of intersection
						s = sDist0/(sDist0 - sDist1);
						t = 0 ;
						
						//	Grab the vertices
						p = vertex[ v1 ];
						q = vertex[ v0 ];
						
						//	Compute the difference vector
						d = p.subtract(q); 
						
						//	Compute the point of intersection
						v = q.add(d.scaleBy(s));
						
						//	Store the new vertex index
						index = vertices.push( v )-1;
						edgeMap[value] = { vertex: v, index: index } ;
						
						
						//	Compute the new texture coordinates
						var u:Number = u0 + (u1 - u0)*s + (u2 - u0)*t ;
						var v:Number = v0 + (v1 - v0)*s + (v2 - v0)*t ;
						
						//	Shove the new texture coordinates on the end of the list
						uv.push( u );
						uv.push( v );
						
						//	Put the new edge on the edges list
						if ( sDist0 > 0 ) {
							edges.push( new Edge( v0, index ));
						} else if ( sDist1 > 0 ) {
							edges.push( new Edge( v1, index ));
						}
					}
				}

				//	Process an intersection on the second edge
				if ((sDist1 > 0 && sDist2 < 0)
					||  (sDist1 < 0 && sDist2 > 0))
				{
					//	Grab the edge we're about split
					edge = edges[ triangle.edges[1]] ;
					value = edge.valueOf();
					if (!edgeMap[value])
					{
						//	Turn the edge off because we split it
						edge.visible = false ;
						
						//	Calculate the value of the line parameter
						//	at the point of intersection
						s = sDist1/(sDist1 - sDist2);
						t = ( 1 - s );
						
						//	Grab the vertices
						p = vertex[ v2 ];
						q = vertex[ v1 ];
						
						//	Compute the difference vector
						d = p.subtract(q); 
						
						//	Compute the point of intersection
						v = q.add(d.scaleBy(s));
						
						//	Store the new vertex index
						index = vertices.push( v )-1;
						edgeMap[value] = { vertex: v, index: index } ;
						
						
						//	Compute the new texture coordinates
						var u:Number = u0 + (u1 - u0)*s + (u2 - u0)*t ;
						var v:Number = v0 + (v1 - v0)*s + (v2 - v0)*t ;
						
						//	Shove the new texture coordinates on the end of the list
						uv.push( u );
						uv.push( v );
						
						//	Put the new edge on the edges list
						if ( sDist1 > 0 ) {
							edges.push( new Edge( v1, index ));
						} else if ( sDist2 > 0 ) {
							edges.push( new Edge( v2, index ));
						}
					}
				}

				
				if ((sDist2 > 0 && sDist0 < 0)
					||  (sDist2 < 0 && sDist0 > 0))
				{
					//	Grab the edge we're about split
					edge = edges[ triangle.edges[2]] ;
					value = edge.valueOf();
					if (!edgeMap[value])
					{
						//	Turn the edge off because we split it
						edge.visible = false ;
						
						//	Calculate the value of the line parameter
						//	at the point of intersection
						t = sDist2/(sDist2 - sDist0);
						s = 0 ;
						
						//	Grab the vertices
						p = vertex[ v0 ];
						q = vertex[ v2 ];
						
						//	Compute the difference vector
						d = p.subtract(q); 
						
						//	Compute the point of intersection
						v = q.add(d.scaleBy(t));
						
						//	Store the new vertex index
						index = vertices.push( v ) -1;
						edgeMap[value] = { vertex: v, index: index } ;
						
						
						//	Compute the new texture coordinates
						var u:Number = u0 + (u1 - u0)*s + (u2 - u0)*t ;
						var v:Number = v0 + (v1 - v0)*s + (v2 - v0)*t ;
						
						//	Shove the new texture coordinates on the end of the list
						uv.push( u );
						uv.push( v );
						
						//	Put the new edge on the edges list
						if ( sDist2 > 0 ) {
							edges.push( new Edge( v2, index ));
						} else if ( sDist0 > 0 ) {
							edges.push( new Edge( v0, index ));
						}
					}
				}

			}
		}
		private function clipTriangles():void 
		{
			var n:int = triangles.length ;
			for (var i:int = 0; i < n; i++)
			{
				var triangle:Triangle = triangles[i] ;
				if ( !triangle.visible )
					continue ;
				
				var v0:int = triangle.index[0] ;
				var v1:int = triangle.index[1] ;
				var v2:int = triangle.index[2] ;
				var e0:int = triangle.edges[0] ;
				var e1:int = triangle.edges[1] ;
				var e2:int = triangle.edges[2] ;
				var sDist0:Number = distances[triangle.index[0]];
				var sDist1:Number = distances[triangle.index[1]];
				var sDist2:Number = distances[triangle.index[2]];
				
				if (sDist0 > 0)
				{
					if (sDist1 > 0)
					{
						if (sDist2 > 0)
						{
							// +++
							continue ;
						}
						else if (sDist2 < 0)
						{
							// ++-
							triangle.visible = false ;
							SplitTrianglePPM(v0,v1,v2,e0,e1,e2);
						}
						else
						{
							// ++0
							continue ;
						}
					}
					else if (sDist1 < 0)
					{
						if (sDist2 > 0)
						{
							// +-+
							triangle.visible = false ;
							SplitTrianglePPM(v2, v0, v1, e2, e0, e1);
						}
						else if (sDist2 < 0)
						{
							// +--
							triangle.visible = false ;
							SplitTriangleMMP(v1, v2, v0, e1, e2, e0);
						}
						else
						{
							// +-0
							triangle.visible = false ;
							SplitTrianglePMZ(v0, v1, v2, e0, e1, e2);
						}
					}
					else
					{
						if (sDist2 > 0)
						{
							// +0+
							continue ;
						}
						else if (sDist2 < 0)
						{
							// +0-
							SplitTriangleMPZ(v2, v0, v1, e2, e0, e1);
						}
						else
						{
							// +00
							continue ;
						}
					}
				}
				else if (sDist0 < 0)
				{
					if (sDist1 > 0)
					{
						if (sDist2 > 0)
						{
							// -++
							triangle.visible = false ;
							SplitTrianglePPM(v1, v2, v0, e1, e2, e0);
						}
						else if (sDist2 < 0)
						{
							// -+-
							triangle.visible = false ;
							SplitTriangleMMP(v2, v0, v1, e2, e0, e1);
						}
						else
						{
							// -+0
							triangle.visible = false ;
							SplitTriangleMPZ(v0, v1, v2, e0, e1, e2);
						}
					}
					else if (sDist1 < 0)
					{
						if (sDist2 > 0)
						{
							// --+
							triangle.visible = false ;
							SplitTriangleMMP(v0, v1, v2, e0, e1, e2);
						}
						else if (sDist2 < 0)
						{
							// ---
							triangle.visible = false ;
							continue ;
						}
						else
						{
							// --0
							triangle.visible = false ;
							continue ;
						}
					}
					else
					{
						if (sDist2 > 0)
						{
							// -0+
							triangle.visible = false ;
							SplitTrianglePMZ(v2, v0, v1, e2, e0, e1);
						}
						else if (sDist2 < 0)
						{
							// -0-
							triangle.visible = false ;
							continue ;
						}
						else
						{
							// -00
							triangle.visible = false ;
							continue ;
						}
					}
				}
				else
				{
					if (sDist1 > 0)
					{
						if (sDist2 > 0)
						{
							// 0++
							continue ;
						}
						else if (sDist2 < 0)
						{
							// 0+-
							triangle = false ;
							SplitTrianglePMZ(v1, v2, v0, e1, e2, e0);
						}
						else
						{
							// 0+0
							continue ;
						}
					}
					else if (sDist1 < 0)
					{
						if (sDist2 > 0)
						{
							// 0-+
							triangle.visible = false ;
							SplitTriangleMPZ(v1, v2, v0, e1, e2, e0);
						}
						else if (sDist2 < 0)
						{
							// 0--
							triangle.visible = false ;
							continue ;
						}
						else
						{
							// 0-0
							triangle.visible = false ;
							continue ;
						}
					}
					else
					{
						if (sDist2 > 0)
						{
							// 00+
							continue;
						}
						else if (sDist2 < 0)
						{
							// 00-
							triangle.visible = false ;
							continue ;
						}
						else
						{
							// 000, reject triangles lying in the plane
							triangle.visible = false ;
							continue ;
						}
					}
				}			
			}
		}
		
		//----------------------------------------------------------------------------
		private function SplitTrianglePPM ( v0:int, v1:int, v2:int, e0:int, e1:int, e2:int ):void
		{
			var triangle:Triangle ;
			var v12:int = edgeMap[new Edge(v1,v2).valueOf()].index;
			var v20:int = edgeMap[new Edge(v2,v0).valueOf()].index;
			triangle = new Triangle(v0,v2,v12) ;
			triangles.push(triangle);
			triangle.edges[0] = e2 ;
			triangle.edges[1] = edges.push( new Edge( v2, v12 ))-1;
			triangle.edges[2] = edges.push( new Edge( v12, v0 ))-1;
			triangle = new Triangle(v0,v12,v20);
			triangles.push(triangle);
			triangle.edges[0] = edges.push( new Edge( v0, v12 ))-1; 
			triangle.edges[1] = edges.push( new Edge( v12, v20 ))-1;
			triangle.edges[2] = edges.push( new Edge( v20, v0 ))-1;
		}
		//----------------------------------------------------------------------------
		private function SplitTriangleMMP ( v0:int, v1:int, v2:int, e0:int, e1:int, e2:int ):void
		{
			
			var v12:int = edgeMap[new Edge(v1,v2).valueOf()].index;
			var v20:int = edgeMap[new Edge(v2,v0).valueOf()].index;
			var triangle:Triangle = new Triangle(v2,v20,v12);
			triangles.push( triangle );
			triangle.edges[0] = edges.push( new Edge( v2, v20 ))-1;
			triangle.edges[1] = edges.push( new Edge( v20, v12 ))-1;
			triangle.edges[2] = edges.push( new Edge( v12, v2 ))-1;
		}
		//----------------------------------------------------------------------------
		private function SplitTrianglePMZ ( v0:int, v1:int, v2:int, e0:int, e1:int, e2:int ):void
		{
			var v01:int = edgeMap[new Edge(v0,v1).valueOf()].index;
			var triangle:Triangle = new Triangle(v2,v0,v01);
			triangles.push( triangle );
			triangle.edges[0] = e2 ;
			triangle.edges[1] = edges.push( new Edge( v0, v01 ))-1;
			triangle.edges[2] = edges.push( new Edge( v01, v2 ))-1;
		}
		//----------------------------------------------------------------------------
		private function SplitTriangleMPZ ( v0:int, v1:int, v2:int, e0:int, e1:int, e2:int ):void
		{
			var v01:int = edgeMap[new Edge(v0,v1).valueOf()].index;
			var triangle:Triangle = new Triangle(v2,v01,v1);
			triangles.push( triangle );
			triangle.edges[0] = edges.push( new Edge( v2, v01 ))-1;
			triangle.edges[1] = edges.push( new Edge( v01, v1 ))-1;
			triangle.edges[2] = e1;
		}
	}
}