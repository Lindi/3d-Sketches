package 
{
	import flash.geom.Vector3D;
	
	import math.Matrix3x3;
	import math.Matrix4x4;
	
	public class Confetti
	{
		private var _position:Vector3D ;
		private var _vertices:Vector.<Vector3D> ;
		private var _orientation:Matrix3x3 ;
		private var _color:Number ;
		private var _scale:Number;
		private var _xangle:Number, _yangle:Number, _zangle:Number ;
		private var _xomega:Number, _yomega:Number, _zomega:Number ;
		public var COSINE_OMEGA:Number ;
		public var SINE_OMEGA:Number ;
		public var velocity:Number ;

		public function Confetti()
		{
			//	|  1  0  0 |
			//	|  0  1  0 |
			//	|  0  0 -1 |
			_orientation = new Matrix3x3( );
			_orientation.identity() ;
			_orientation.set( 2, 2, -1 );

			//	The quad's local vertices
			_vertices = new Vector.<Vector3D>(4);
			_vertices[0] = new Vector3D( 1, 1, 0, 1 ) ;
			_vertices[1] = new Vector3D( -1, 1, 0, 1 ) ;
			_vertices[2] = new Vector3D( 1, -1, 0, 1 ) ;
			_vertices[3] = new Vector3D( -1, -1, 0, 1 ) ;
			
			//	Set the current rotation angles
			_xangle = int( Math.random() * 360 ) ;
			_yangle = int( Math.random() * 360 ) ;
			_zangle = int( Math.random() * 360 ) ;
			
			//	Set the rotation angular velocities
			_xomega = -80 + int( Math.random() * 160 ) ;
			_yomega = -80 + int( Math.random() * 160 ) ;
			_zomega = -80 + int( Math.random() * 160 ) ;
			
			//	Calculate the cosine and sine of the angular velocity
			COSINE_OMEGA = Math.cos(( -_zomega / 60 ) * ( Math.PI / 180 ));
			SINE_OMEGA = Math.sin(( -_zomega / 60 ) * ( Math.PI / 180 ));
		}
		
		/**
		 * Transform each of the vertices by the rotation matrix 
		 * 
		 */		
		internal function rotate( vertices:Vector.<Vector3D> ):void
		{
			//	TODO: Implement with quaternions
			_xangle += _xomega ; _xangle %= 360 ;
			_yangle += _yomega ; _yangle %= 360 ;
			_zangle += _zomega ; _zangle %= 360 ;
			
			var rotation:Matrix4x4 = Matrix4x4.Rotation( _xangle, _yangle, _zangle ) ;

			var vector:Vector3D = rotation.transform( vertices[0] );
			vertices[0].x = vector.x; vertices[0].y = vector.y; vertices[0].z = vector.z ;
			vector = rotation.transform( vertices[1] );
			vertices[1].x = vector.x; vertices[1].y = vector.y; vertices[1].z = vector.z ;
			vector = rotation.transform( vertices[2] );
			vertices[2].x = vector.x; vertices[2].y = vector.y; vertices[2].z = vector.z ;
			vector = rotation.transform( vertices[3] );
			vertices[3].x = vector.x; vertices[3].y = vector.y; vertices[3].z = vector.z ;
		}
				
		public function set position( position:Vector3D ):void
		{
			_position = position ;
		}
		
		public function get position():Vector3D
		{
			return _position ;
		}
		
		public function get radius():Number
		{
			return _scale/2 ;
		}
		
		
		public function set scale( scale:Number ):void
		{
			_scale = scale ;
		}
		
		internal function get vertices( ):Vector.<Vector3D>
		{
			//	Make a copy of the local vertices
			var vertices:Vector.<Vector3D> = new Vector.<Vector3D>(4);
			vertices[0] = _vertices[0].clone();
			vertices[1] = _vertices[1].clone();
			vertices[2] = _vertices[2].clone();
			vertices[3] = _vertices[3].clone();
			return vertices ;
		}

		public function get color():Number
		{
			return _color ;
		}
		
		public function set color( color:Number ):void
		{
			_color = color ;
		}
		/**
		 * Returns the camera's transform matrix 
		 * @return 
		 * 
		 */		
		public function get localToWorldTransform():Matrix4x4 
		{
			//	Make a clone of the original rotation matrix
			//	I wonder if we should just transpose the original matrix?
			var rotation:Matrix3x3 = _orientation.clone().transpose() ;
			rotation.scale( _scale ) ;
			
			//	Calculate the translation vector
			var translation:Vector3D = rotation.transform( _position ) ;
			
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