package com.madsystems.components._3d
{
	import flash.geom.Vector3D;
	import flash.geom.Point ;
	import flash.utils.Dictionary;

	public class Mesh
	{
		public var vertex:Vector.<Vertex> ;
		public var edges:Vector.<Edge> ;
		public var uv:Vector.<Number> ;
		public var index:Vector<Number> ;
		public var triangles:Vector.<Triangle> ;
		
		public function Mesh( width:Number = 2000, height:Number = 1500, rows:uint = 3, cols:uint = 3 )
		{
			//	Calculate the number of vertices
			var n:uint = rows * cols ;
			
			//	Create the list that will store them
			vertex = new Vector.<Vertex>(n,true);
			
			//	Create the texture coordinate list
			uv = new Vector.<Number>(n*2,true);
			
			//	Iterate through each row
			for (var i:int = 0, k:int = 0; i < rows; i++)
			{
				//	Calculate the vertical texture mapping percentages
				var v:Number = Number(i)/Number(rows-1);
				
				//	Iterate through each column
				for (var j:int = 0; j < cols; j++)
				{
					//	Calculate the horizontal texture mapping percentages
					var u:Number = Number(j)/Number(cols-1);
					 
					var x:Number = ( 2.0 * u - 1.0 ) * width/2 ;
					var y:Number = ( 2.0 * v - 1.0 ) * height/2 ;
					var z:Number = 0.0 ;
					
					//	Store the texture coordinates
					uv[k * 2] = u ;
					uv[k * 2 + 1] = v;
					
					//	Store the newly created vertex
					vertices[k++] = new Vertex(x,y,z);
				}
			}
			
			//	Calculate the number of triangles
			n = (rows-1) * (cols-1) * 2 ;  
			
			//	Create the list of triangles
			triangles = new Vector.<Triangle>(n,true);

			//	Create the list of edges
			edges = new Vector.<Edge>();

			//	Local variable reference pointers
			var edge:Edge ;
			var triangle:Triangle ;
			var index:int ;
			var value:Number ;
			var dictionary:Dictionary = new Dictionary();
			 
			//	Define a function to add an edge indexes to the edge
			//	list for each triangle
			var addEdges:Function = 
			function ( triangle:Triangle ):void {
				for ( var k:int = 0; k < 3; k++ ) {
					edge = new Edge( triangle.index[k], triangle.index[(k+1) % 3]);
					value = edge.valueOf();
					if ( !dictionary[ value ])
						dictionary[value] = index = edges.push( edge );
					else index = int( dictionary[ value] );
					triangle.edges[k] = index ;
				}

			}
			
			//	Create the triangles
			for (i = 0, k = 0; i < rows - 1; i++)
			{
				for (j = 0; j < cols - 1; j++)
				{
					var v0:int = i * cols + j;
					var v1:int = v0 + 1;
					var v2:int = v1 + cols;
					var v3:int = v0 + cols;
					
					triangles[k++] = triangle = new Triangle(v0,v1,v2);
					//addEdges( triangle );
					triangles[k++] = triangle = new Triangle(v0,v2,v3);
					//addEdges( triangle );
				}
			}
		}
		
			
		
		public function draw():void {
			
		}
	}
}