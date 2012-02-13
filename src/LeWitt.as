package
{
	import _3d.Camera;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import geometry.Quaternion;
	import geometry.Vector2d;
	
	import math.Matrix4x4;
	import math.Utils;

	[SWF(backgroundColor='#ffffff', width='400', height='400')]
	public class LeWitt extends Sprite
	{
		private var _lineSegments:Vector.<Vector.<int>> ;
		private var _points:Vector.<Vector3D> ;
		private var _currentAxis:Vector3D ;
		private var _index:int ;
		private var _count:int ;
		private var _camera:Camera ;
		private var _worldUp:Vector3D ;
		private static const SEGMENT_LENGTH:int = 20 ;
		private static const RADIANS:Number = Math.PI / 180 ;
		private static const COSINE_RADIANS:Number = Math.cos( RADIANS ) ;
		private static const SINE_RADIANS:Number = Math.sin( RADIANS ) ;


		public function LeWitt()
		{
			super();
			
			//	Create a collection of points and line segments
			_points = new Vector.<Vector3D>();
			_lineSegments = new Vector.<Vector.<int>>();
			
			//	Make a new camera
			_camera = new Camera();
			_camera.position = new Vector3D( );
			_camera.position.x = 0 ;
			_camera.position.y = 0 ;
			_camera.position.z = -100 ;
			_camera.position.w = 1 ;
			_camera.width = stage.stageWidth ;
			_camera.height = stage.stageHeight ;
			_camera.setPerspective( 50, _camera.width/_camera.height, 40, 20000 ) ; 
			_camera.getScreenTransformMatrix( stage.stageWidth, stage.stageHeight ) ;
			
			//	Start by creating a line segment
			createLineSegment();
			addEventListener( Event.ENTER_FRAME, frame ) ;
		}
		
		/**
		 * Creates a line segment 
		 * @return 
		 * 
		 */		
		private function createLineSegment( ):void
		{
			var lineSegment:Vector.<int> = new Vector.<int>(2,true);
			
			//	Pick a point
			var axis:Vector3D ;
			var point:Vector3D ;
			if ( _points.length == 0 )
			{
				point = getRandomPoint( 100 );
				axis = pickAxis(int( Math.random() * 3 )) ;
				while (( _currentAxis = pickAxis(int( Math.random() * 3 ))) == axis ) {} ;
				_points.push(point) ;
			} else {
				point = _points[ _points.length - 1].clone();
				while (( axis = pickAxis(int( Math.random() * 3 ))) == _currentAxis ) {} ;
				_currentAxis = axis ;
				_points.push(point);
			}
			axis = axis.clone() ;
			axis.scaleBy( SEGMENT_LENGTH );
			_points.push(point.add( axis )) ;
			_points.push( _points[ _points.length - 1].clone());
		}
		
		
		/**
		 * Returns the x, y or z axis 
		 * 
		 */		
		private function pickAxis( index:int ):Vector3D
		{
			if ( index < 0 || index > 3 || isNaN( Number( index )))
			{
				index = int( Math.random() * 3 ) ;
			}
			return ( index == 0 ? Vector3D.X_AXIS :
				( index == 1 ? Vector3D.Y_AXIS : Vector3D.Z_AXIS ));
		}
		/**
		 * Returns a random three-dimensional point 
		 * @return Vector3D
		 * 
		 */		
		private function getRandomPoint( scale:Number ):Vector3D
		{
			var p:Vector3D = new Vector3D();
			p.x = Math.random() * scale ;
			p.y = Math.random() * scale ;
			p.z = Math.random() * scale ;
			p.w = 1 ;
			return p ;
		}
		
		/**
		 * Returns a point that is not on the line segment defined by points a and b
		 * To ensure that the point is not on the line, the cross
		 * product of the vector ( b - a ) and the vector ( c - a )
		 * must be a non-zero vector.
		 *  
		 * @return Vector3D
		 * 
		 */		
		private function getNonCollinearPoint( a:Vector3D, b:Vector3D ):Vector3D
		{
			//	TODO: Re-write using cross-product
			var line:Vector3D = a.crossProduct( b ) ;
			while ( true )
			{
				var c:Vector3D = getRandomPoint( SEGMENT_LENGTH );
				if ( !Utils.IsZero( c.dotProduct( line )))
					return c ;
			}
			return null ;
		}
				
		/**
		 * Frame event handler 
		 * @param event
		 * 
		 */		
		private function frame( event:Event ):void
		{
			if ( _index == 0 )
			{
				if (_count++ > 20 ) 
					removeEventListener( Event.ENTER_FRAME, frame ) ;
				else createLineSegment( ) ;
			}
			//	Take the vector defined by newSegment[1] - newSegment[0] 
			//	and rotate it around the current axis every 50 frames
			var t:Number = (_index++)/SEGMENT_LENGTH ;
			_index %= SEGMENT_LENGTH ;
			
			//	It'd be smarter to create these once per
			//	line segment in the createNewLineSegment handler
			var axis:Vector3D ;
			if ( _count % 2 )
			{
				axis = _currentAxis.clone();
				axis.negate();
			} else
			{
				axis = _currentAxis ;
			}
			var from:Quaternion = new Quaternion();
			from.SetAxisAngle( axis, 0 );
			var to:Quaternion = new Quaternion();
			to.SetAxisAngle( axis, Math.PI / 2 );
			
			//	Interpolate using slerp
			var quaternion:Quaternion = Quaternion.Slerp( from, to, t );
			
			//	Grab the points of the current line segment, and calculate
			//	the vector obtained by subtracting b from a
			var a:Vector3D = _points[ _points.length - 3 ] ;
			var b:Vector3D = _points[ _points.length - 2 ] ;
			var d:Vector3D = b.subtract( a ) ;
			d.scaleBy( 1/SEGMENT_LENGTH );
			

			
			//	Create a quaternion from this vector, and transform it
			//	by the interpolated quaterion (should refactor this into a function)
			//	Here's a problem though.  If we modify the endpoint of the line
			//	segment, we're going to end up interpolating a modified point.
			//	We don't want to do this, so we should create a duplicate of the
			//	current segment's enpoint and store it somewhere
			var vector:Quaternion = new Quaternion( 0, d.x, d.y, d.z );
			var inverse:Quaternion = quaternion.Inverse();
			var product:Quaternion = vector.Multiply( inverse ) ;
			product = quaternion.Multiply( product ) ;
			
			
			//	Create
			//	Modify the current segment
			var q:Vector3D = new Vector3D( product.x, product.y, product.z ) ;
			q.scaleBy( SEGMENT_LENGTH ) ;
			var v:Vector3D = _points[ _points.length-1] ;
			var w:Vector3D = v.add( q );
			v.x = w.x ; v.y = w.y ; v.z = w.z ;
			
			_camera.position.x = v.x + axis.x * SEGMENT_LENGTH ;
			_camera.position.y = v.y + axis.y * SEGMENT_LENGTH ;
			_camera.position.z = v.z + axis.z * SEGMENT_LENGTH ;
			
//			var angle:Number = 1 * RADIANS ;
//			var x:Number = _camera.position.x ;
//			var z:Number = _camera.position.z ;
//			_camera.position.x = COSINE_RADIANS * x - SINE_RADIANS * z;
//			_camera.position.z = COSINE_RADIANS * z + SINE_RADIANS * x;
//			_camera.position.w = 1 ;
			_worldUp = new Vector3D( -_camera.position.z, 0, _camera.position.x ) ;
			_worldUp.normalize() ;
			
			
			//	Iterate over the confetti and compute their projections
			var worldToView:Matrix4x4 = _camera.lookAt( new Vector3D( v.x, v.y, v.z, 1), _worldUp ) ;//_camera.transform;_ ; //_camera.lookAt( new Vector3D(0,300,0), Vector3D.Z_AXIS ) ;
			var projection:Matrix4x4 = _camera.perspective ;
			var screenTransform:Matrix4x4 = _camera.getScreenTransformMatrix( ) ;
			
			//	Keep a collection of points we're transforming
			var transformedPoints:Vector.<Vector3D> = new Vector.<Vector3D>( );
			
			//	Iterate over all the line segments
			for ( var j:int = 0; j < _points.length-1; j++ )
			{
				//	Grab the current line segment
				a = _points[j].clone() ;
				b = _points[j+1].clone() ;
				a = worldToView.transform( a ) ;
				b = worldToView.transform( b ) ;
				
				//	Clip the line segment a-b
				var clip:Vector.<Vector3D> = _camera.clip( a, b ) ;
				if ( clip != null )
				{
					//	TODO: Clip the points as well
					//	Add the transformed points to the collection
					//	of transformed points
					a = clip[0] ;
					b = clip[1] ;	
					a = projection.transform( a );
					a.project();
					a.w = 1 ;
					a = screenTransform.transform( a ) ;
					transformedPoints.push( a ) ;
					b = projection.transform( b );
					b.project();
					b.w = 1 ;
					b = screenTransform.transform( b ) ;
					transformedPoints.push( b ) ;
				}
			}
			
			//	 Draw all the line segments
			//	The number of transformed points should always be even
			graphics.clear(); 
			graphics.lineStyle( undefined ) ;
			for ( j = 0; j < transformedPoints.length; j+= 2 )
			{
				a = transformedPoints[j] ;
				b = transformedPoints[j+1] ;
				if ( j < length-1 )
					graphics.beginFill( 0x000000 ) ;
				else graphics.beginFill( 0xff0000 );
				graphics.drawCircle( a.x, a.y, 1 ) ;
				graphics.drawCircle( b.x, b.y, 1 ) ;
				graphics.endFill() ;
				graphics.lineStyle( 1, 0x000000 ) ;
				graphics.moveTo( a.x, a.y );
				graphics.lineTo( b.x, b.y ) ;
			}
		}
	}
}