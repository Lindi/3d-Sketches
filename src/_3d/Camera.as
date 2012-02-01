package _3d
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import geometry.Plane;
	
	import math.Matrix3x3;
	import math.Matrix4x4;

	public class Camera
	{
		
		private static const SQRT2:Number = Math.sqrt(2);

		//	Eye point
		private var _eye:Vector3D ;
		
		//	Direction vector
		private var _direction:Vector3D ;
		
		//	Up vector
		private var _up:Vector3D ;
		
		//	Side vector
		private var _side:Vector3D ;
		
		//	Width and height of the view plane
		private var _width:Number = 2;
		private var _height:Number = 2;
		
		//	Distance to the near and far view planes
		private var _near:Number ;
		private var _far:Number ;
		
		//	Distance to the view plane
		private var _distance:Number ;
		
		//	Initial orientation
		private var _orientation:Matrix3x3 ;
		
		//	Perspective matrix
		private var _perspective:Matrix4x4 ;
		private var _screen:Matrix4x4 ;
		
		//	Create some frustum planes for testing
		private var _planes:Vector.<Plane> ;
		
		
		public function Camera(  ) 
		{
			//	Set the orthogonal frame of the camera
			_direction = Vector3D.Z_AXIS.clone() ;
			_direction.negate();
			_up = Vector3D.Y_AXIS.clone() ;
			_side = Vector3D.X_AXIS.clone() ;
			
			//	|  0 -1  0 |
			//	|  0  0  1 |
			//	| -1  0  0 |
			//			_orientation.set( 0, 0, 0 );
			//			_orientation.set( 0, 2, -1 );
			//			_orientation.set( 1, 0, -1 );
			//			_orientation.set( 1, 1, 0 );
			//			_orientation.set( 2, 1, 1 );
			//			_orientation.set( 2, 2, 0 );

			//	|  1  0  0 |
			//	|  0  0  1 |
			//	|  0  1  0 |
			_orientation = new Matrix3x3( );
			_orientation.identity() ;
			_orientation.set( 1, 1, 0 );
			_orientation.set( 2, 1, 1 );
			_orientation.set( 1, 2, 1 );
		}
		
		public function set position( position:Vector3D ):void
		{
			_eye = position ;
		}
		
		public function get direction(  ):Vector3D
		{
			return _direction ;
		}

		public function set direction( direction:Vector3D ):void
		{
			_direction = direction ;
		}
		
		public function set up( up:Vector3D ):void
		{
			_up = up ;
		}
		
		public function set side( side:Vector3D ):void
		{
			_side = side ;
		}
		
		public function get height( ):Number 
		{
			return _height ;
		}
		
		public function set height( height:Number ):void
		{
			_height = height ;
		}
		
		public function get width( ):Number 
		{
			return _width ;
		}
		
		public function set width( width:Number ):void
		{
			_width = width ;	
		}
		
		public function get position( ):Vector3D
		{
			return _eye ;
		}
		
		
		/**
		 * Set this camera's perspective matrix.  Actually, this
		 * probably belongs somewhere else, like in a 'display' 
		 * or 'frustum' class, but I'll put it here for now.
		 * 
		 * So, the interesting thing is that this function requires that
		 * the near and far z bet set beforehand, but I'm not sure how
		 * that guarantees that the distance to the projection plane is
		 * less than the near distance (which it has to be in a properly
		 * formed view frustum).
		 * 
		 * Ohhhh, I see.  The distance to the frustum plane is calculated with
		 * a normalized view plane height of 1.  So the near and far z values are
		 * arbitrary
		 * 
		 * @param fov
		 * @param aspect
		 * @param nearZ
		 * @param farZ
		 * 
		 */		
		public function setPerspective( fov:Number, aspect:Number, nearZ:Number, farZ:Number ):void
		{
			//	Keep track of the near and far z
			_near = nearZ ;
			_far = farZ ;
			
			//	The distance to the projection plane
			var d:Number = _distance = 1.0/Math.tan(fov/180*Math.PI*0.5);
			var recip:Number = 1.0/(nearZ-farZ);
			_perspective = new Matrix4x4( ) ;
			_perspective.set(0,0,d/aspect);
			_perspective.set(1,1, d );
			_perspective.set(2,2, (nearZ+farZ)*recip);
			_perspective.set(2,3,2*nearZ*farZ*recip);
			_perspective.set(3,2, -1.0);
			_perspective.set(3,3, 0.0);
			
			//	Create the frustum planes
			_planes = new Vector.<Plane>(  ) ;
			
			//	Right plane
			var plane:Plane ;
			plane = new Plane();
			plane.setCoefficients( -1, 0, ( _width/2/_near ), 0 );
			_planes.push( plane ) ;
			
			//	Left plane
			plane = new Plane();
			plane.setCoefficients( 1, 0, ( _width/2/_near ), 0 );
			_planes.push( plane ) ;

			//	Top plane
			plane = new Plane();
			plane.setCoefficients( 0, -1, ( _height/2/_near ), 0 );
			_planes.push( plane ) ;
			
			//	Bottom plane
			plane = new Plane();
			plane.setCoefficients( 0, 1, ( _height/2/_near ), 0 );
			_planes.push( plane ) ;
//			
			//	Near plane
			plane = new Plane();
			plane.setCoefficients( 0, 0, 1, -_near  );
			_planes.push( plane ) ;
//			//	Far plane
//			_planes[5] = new Plane();
//			_planes[5].setCoefficients( 0, 0, -1, _far );
		}
		
		/**
		 * Returns true if the point is within the view frustum
		 * False, if not 
		 * @param point
		 * @return 
		 * 
		 */		
		public function test( point:Vector3D ):Boolean
		{
			for ( var i:int = 0; i < _planes.length; i++ )
			{
				var plane:Plane = _planes[i] ;
				var distance:Number = plane.test( point );
				if ( distance < 0 )
					return false ;
			}
			return true ;
		}
		
		/**
		 * Clips the line segment against the frustum planes
		 * If both points are outside all the planes, we return null
		 * Otherwise, we return a vector of two points. 
		 * @param a
		 * @param b
		 * 
		 */		
		public function clip( a:Vector3D, b:Vector3D ):Vector.<Vector3D>
		{
			var result:Vector.<Vector3D> = new Vector.<Vector3D>(2,true);
			for ( var i:int = 0; i < _planes.length; i++ )
			{
				var plane:Plane = _planes[i] ;
				var adistance:Number = plane.test( a );
				var bdistance:Number = plane.test( b );
				if (!( adistance > 0 && bdistance > 0 ))
				{
					break ;
				}
			}	
			if ( adistance < 0 && bdistance < 0 )
			{
				//	If they're both outside the plane, return nothing
				return null ;
			}

			if ( i == _planes.length )
			{
				//	If they're both inside the plane, return the same points
				result[0] = a ;
				result[1] = b ;
				
			} else if ( adistance > 0 && bdistance < 0 )
			{
				//	b is outside the plane, so replace b
				var bca:Number = bc( a, plane ) ;
				var bcb:Number = bc( b, plane ) ;
				var d:Vector3D = a.subtract( b ) ;
				var t:Number = bca / ( bcb - bca ) ;
				d.scaleBy( t ) ;
				result[0] = a.add( d ) ;
				result[1] = b ;
				
			} else if ( adistance < 0 && bdistance > 0 )
			{
				//	a is outside the plane, so replace a 
				bca = bc( a, plane ) ;
				bcb = bc( b, plane ) ;
				d = b.subtract( a ) ;
				t = bca / ( bcb - bca ) ;
				d.scaleBy( t ) ;
				result[0] = b.add( a ) ;
				result[1] = b ;
			}
			return result ;
		}
		
		
		private function bc( p:Vector3D, plane:Plane ):Number
		{
			return plane.a * p.x + plane.b * p.y + plane.c * p.z + plane.d ;	
		}

		/**
		 * Get the perspective projection matrix 
		 * @return 
		 * 
		 */		
		public function get perspective( ):Matrix4x4
		{
			return _perspective ;
		}
		
		/**
		 * Gets the screen transform 
		 * @return 
		 * 
		 */		
		public function getScreenTransformMatrix( width:Number = Number.NaN, height:Number = Number.NaN):Matrix4x4
		{
			//	TODO: Clean up the arguments 
			if ( _screen == null )
			{
				width = ( isNaN( width ) ? _width : width ) ;
				height = ( isNaN( height ) ? _height : height ) ;
				_screen = new Matrix4x4( ) ;
				_screen.data[0] = width/2 ;
				_screen.data[12] = width/2 ;			
				_screen.data[5] = -height/2 + (_near * (1/SQRT2)) ;
				_screen.data[13] = height/2 ;
				_screen.data[10] = .5;
				_screen.data[14] = .5;
				_screen.data[15] = 1 ;
				
			}
			return _screen ;
		}

		/**
		 * Orients the camera to look at a certain point 
		 * Should we set our instance-level orthonormal frame vectors
		 * to those that we compute here?
		 * @param point
		 * 
		 */		
		public function lookAt( point:Vector3D, worldUp:Vector3D ):Matrix4x4 
		{
			//	Compute the view or direction normalized vector
			//	by subtracting the point we're looking from the camera position
			_direction = point.subtract( _eye ) ;
			_direction.normalize();
			
			//	Compute the right-handed vector by taking the cross
			//	product of the view vector with the world up vector
			//	The world up-vector denotes the direction "up" in the world
			//	We have to make sure that our camera direction vector
			//	is never parallel with the world up vector to ensure
			//	that we can always compute a set of orthonomral basis vectors
			_side =  _direction.crossProduct( worldUp );
			_side.normalize();
			//side.negate();
			
			//	Compute the up vector component of the orthonormal basis vectors
			_up =  _side.crossProduct( _direction );
			_up.normalize();
			
			//	When computing the view-to-world transform matrix, you set
			//	the first column of the matrix to the side or right vector,
			//	the second column of the matrix to the up vector and
			//	the third column of the matrix to the direction vector
			//	By doing this, you're mapping the world x-axis to the camera's side vector
			//	the world y-axis to the camera's up vector and the world's z-axis to the
			//	camera's direction vector
			
			//	When computing the world-to-view matrix, we must take the transpose of
			//	the view-to-world orientation matrix which is why we're setting the rows
			//	of this matrix.  We negate the direction vector to ensure that it is
			//	oriented along the negative z-axis (Open-GL convention)
			//_direction.negate() ;
			var rotate:Matrix3x3 = new Matrix3x3();
			rotate.setRows( _side, _up, _direction );
			
			//	World->view translation
			var translation:Vector3D = rotate.transform( _eye ) ;
			translation.negate();
			
			//	Build and return the transform matrix
			var transform:Matrix4x4 = new Matrix4x4();
			transform.setRotation( rotate ) ;
			transform.set( 0, 3, translation.x ) ;
			transform.set( 1, 3, translation.y ) ;
			transform.set( 2, 3, translation.z ) ;
			return transform ;			
		}
		
		
		/**
		 * Returns the camera's transform matrix 
		 * @return 
		 * 
		 */		
		public function get transform():Matrix4x4 
		{
			//	Make a clone of the original rotation matrix
			//	I wonder if we should just transpose the original matrix?
			var rotation:Matrix3x3 = _orientation.clone().transpose() ;
			
			//	Calculate the translation vector
			var translation:Vector3D = rotation.transform( _eye ) ;
			
			//	Note: here you can multiply a clone of the intial rotation
			//	matrix by rotation angles
			var transform:Matrix4x4 = new Matrix4x4( );
			transform.setRotation( rotation );
			transform.set( 0, 3, translation.x ) ;
			transform.set( 1, 3, translation.y ) ;
			transform.set( 2, 3, translation.z ) ;
			return transform ;
			
		}
	}
}


