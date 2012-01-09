package 
{ 
	import com.madsystems.components._3d.Frustum;
	import geometry.Plane;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	public class Triangles extends Sprite 
	{ 
		public function Triangles():void 
		{ 
			//	Create the mesh
			//	Create the camera frustum
			//	Create the camera
			//	Position the camera
			//	Transform the frustum plane normals to world space
			//	Cull the mesh vertices
			//	Transform the visible mesh vertices to camera space
			//	Project them
			//	Draw them
			
			var a:Array = new Array();
			trace( a.push( "foo" ));
			
//			var eye:Vector3D = new Vector3D();
//			var d:Vector3D = Vector3D.Z_AXIS ;
//			var u:Vector3D = Vector3D.Y_AXIS ;
//			var r:Vector3D = Vector3D.X_AXIS ;
//			var near:Number = 400 ;
//			var far:Number = 800 ;
//			var width:Number = 1000 ;
//			var height:Number = 750 ;
//			
//			var p:Vector3D = d.clone();
//			p.scaleBy( near * 1.5 ) ;
//			var frustum:Frustum = new Frustum( eye, d, u, r, near, far, width, height );
//			var planes:Vector.<Plane> = frustum.planes ;
//			for each ( var plane:Plane in planes ) {
//				trace( plane.whichSide( p));
//			}
		}  
	}		
}	


//			var dictionary:Dictionary = new Dictionary();
//			var e:Edge = new Edge(0,1);
//			dictionary[e.valueOf()] = e ;
//			var edge:Edge = new Edge(1,0);
//			//dictionary[edge] = edge ;
//			
//			edge = new Edge(0,1);
//			trace( edge.valueOf());
//			trace( e.valueOf());
//			trace( dictionary[edge.valueOf()] is Object );
//			
//			var matrix:Matrix3D = new Matrix3D();
//			matrix.identity();
//			matrix.transpose();
//			for ( var i:int = 0; i < matrix.rawData.length; i++)
//				trace( "matrix.rawData["+i+"]=" + matrix.rawData[i] );
//			
//			var u:Vector3D = new Vector3D();
//			var v:Vector3D = matrix.transformVector(u);
//			trace( u );
//			trace( v );

