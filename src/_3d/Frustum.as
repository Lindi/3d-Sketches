package _3d
{
	import math.Plane;
	
	import flash.geom.Vector3D;

	public class Frustum
	{
		//	Near and far
		public var near:Number ;
		public var far:Number ;
		
		//	Camera eye point/position
		public var eye:Vector3D ;
		
		//	Orthonormal frustum frame basis vectors
		//	Obviously, they should be normalized.  Duh.
		public var d:Vector3D ;
		public var u:Vector3D ;
		public var r:Vector3D

		
		//	Width and Height
		public var width:Number ;
		public var height:Number ;
		
		public var planes:Vector.<Plane> = new Vector.<Plane>();
		

		public function Frustum( eye:Vector3D, d:Vector3D, u:Vector3D, 
								 r:Vector3D, near:Number, far:Number, 
								 width:Number, height:Number ) 
		{
			this.eye = eye ;
			this.d = d ;
			this.u = u ;
			this.r = r ;
			this.near = near ;
			this.far = far ;
			this.width = width ;
			this.height = height ;
			
			var vertex:Vector.<Vector3D> = computeVertices();
			planes = new Vector.<Plane>(6,true);
			//	Near plane
			planes[0] = new Plane(vertex[0], vertex[1], vertex[3]);
			//	Far plane
			planes[1] = new Plane(vertex[5], vertex[4], vertex[6]);
			//	Left plane
			planes[2] = new Plane(vertex[4], vertex[0], vertex[7]);
			//	Right plane
			planes[3] = new Plane(vertex[1], vertex[5], vertex[2]);
			//	Top plane
			planes[4] = new Plane(vertex[3], vertex[2], vertex[7]);
			//	Bottom plane
			planes[5] = new Plane(vertex[1], vertex[0], vertex[5]);
		}
		
		private function computeVertices():Vector.<Vector3D> {
			
			var d:Vector3D = this.d.clone() ;
			d.scaleBy( near );
			
			var u:Vector3D = this.u.clone();
			u.scaleBy( height/2 );
			
			var r:Vector3D = this.r.clone() ;
			r.scaleBy( width/2 );
			
			var vertex:Vector.<Vector3D> = new Vector.<Vector3D>(8,true);
			
			
			vertex[0] = d.subtract(u).subtract(r);
			vertex[1] = d.subtract(u).add(r) ;
			vertex[2] = d.add(u).add(r);
			vertex[3] = d.add(u).subtract(r);
			
			for (var i:int = 0, ip:int = 4; i < 4; ++i, ++ip)
			{
				var v:Vector3D = ( vertex[i] as Vector3D ).clone();
				v.scaleBy( far/near );
				vertex[ip] =  v.add( eye );
				vertex[i] = ( vertex[i] as Vector3D ).add(eye);
			}			
			
			return vertex ;
		}

		
//		private function get perspctive():Matrix3D 
//		{
//			var recipX:Number = 1.0/(right-left);
//			var recipY:Number = 1.0/(top-bottom);
//			var recipZ:Number = 1.0/(near-far);
//			
//			var matrix:Matrix3D = new Matrix3D();
//			
//			matrix[0] = 2.0*near*recipX;
//			matrix[2] = (right+left)*recipX;
//			
//			matrix[5] = 2.0*near*recipY;
//			matrix[6] = (top+bottom)*recipY;
//			
//			matrix[10] = (near+farZ)*recipZ;
//			matrix[11] = 2*near*far*recipZ;
//			
//			matrix[14] = -1.0;
//			matrix[15] = 0.0;
//			matrix.transpose();
//			return matrix ;
//		}
	}
	
}

//			//	Add the right plane
//			planes.push(new Plane(new Vector3D(1,0,-r/n)));
//			
//			//	Add the left plane
//			planes.push(new Plane(new Vector3D(1,0,l/n)));
//
//			//	Add the top plane
//			planes.push(new Plane(new Vector3D(0,1,-t/n)));
//			
//			//	Add the bottom plane
//			planes.push(new Plane(new Vector3D(0,1,b/n)));
//			
//			//	Add the near plane
//			planes.push(new Plane( 0,0,-1, -n));
//			
//			//	Add the far plane
//			planes.push(new Plane( 0,0,1, f));
