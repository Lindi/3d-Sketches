package
{
	import _3d.Camera;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import geometry.Quaternion;
	
	import math.Matrix4x4;
	import math.Utils;

	[SWF(backgroundColor='#ffffff', width='400', height='400')]
	public class LookAt extends Sprite
	{
		private var _lineSegments:Vector.<Vector.<int>> ;
		private var _points:Vector.<Vector3D> ;
		private var _currentLineSegment:int ;
		private var _currentLineSegmentPoints:Vector.<Vector3D> ;  
		private var _currentAxis:Vector3D ;
		private var _index:int ;
		private var _count:int ;
		private var _camera:Camera ;
		private var _worldUp:Vector3D ;
		private static const SEGMENT_LENGTH:int = 20 ;
		private static const RADIANS:Number = Math.PI / 180 ;
		private static const COSINE_RADIANS:Number = Math.cos( RADIANS ) ;
		private static const SINE_RADIANS:Number = Math.sin( RADIANS ) ;


		public function LookAt()
		{
			super();
			
			//	Create a collection of points and line segments
			_points = new Vector.<Vector3D>();
			_currentLineSegmentPoints = new Vector.<Vector3D>(2,true);
			_lineSegments = new Vector.<Vector.<int>>();
			
			//	Make a new camera
			_camera = new Camera();
			_camera.position = new Vector3D( );
			_camera.position.x = 0 ;
			_camera.position.y = 0 ;
			_camera.position.z = -100 ;
			_camera.position.w = 1 ;
			_camera.width = 400 ;
			_camera.height = 400 ;
			_camera.setPerspective( 65, _camera.width/_camera.height, 10, 10000 ) ; 
			_camera.getScreenTransformMatrix( stage.stageWidth, stage.stageHeight ) ;
			
			//	Start by creating a line segment
			createLineSegment();
			addEventListener( Event.ENTER_FRAME, frame ) ;
			_worldUp = Vector3D.X_AXIS.clone();
		}
		
		/**
		 * Creates a line segment 
		 * @return 
		 * 
		 */		
		private function createLineSegment( ):int
		{
			var lineSegment:Vector.<int> = new Vector.<int>(2,true);
			var a:Vector3D = new Vector3D( 0, 0, -200, 1 ) ; //getRandomPoint( 100 );
			lineSegment[0] = _points.push(a) - 1;
			var b:Vector3D = new Vector3D( 100, 0, -200, 1 ) ; //getRandomPoint( 100 );	
//			b.normalize() ;
//			b.scaleBy( 20 ) ;
			lineSegment[1] = _points.push(a.add( b ))-1;
			return _lineSegments.push(lineSegment);
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
		
		private function createNewLineSegment( ):int
		{
			//	Given a line segment, find a vector that's perpendicular to the segment
			var lineSegment:Vector.<int> = _lineSegments[_currentLineSegment] ;
			
			//	First, find a random point that's not on the line segment
			var a:Vector3D = _points[lineSegment[0]] ;
			var b:Vector3D = _points[lineSegment[1]] ;
			var c:Vector3D = getNonCollinearPoint( a, b );
			
			//	Take the cross product of ( b - a ) and ( c - a )
			//	That's the axis around which we'll rotate a new line segment
			_currentAxis = ( b.subtract( a )).crossProduct( c.subtract( a ));
			if ( _count % 2 )
			{
				_currentAxis = _currentAxis.crossProduct( b.subtract( a ));
				_currentAxis.negate() ;
			}
			_currentAxis.normalize();
			
			//	Create a new line segment from the points of the current line segment
			var index:int = Math.floor( Math.random() * 2 );
			var newSegment:Vector.<int> = new Vector.<int>(2,true);
			newSegment[0] = lineSegment[index]; 
			newSegment[1] = _points.push( _points[lineSegment[(index + 1) % 2]].clone()) -1 ; 
			_currentLineSegmentPoints[0] = _points[newSegment[0]].clone();
			_currentLineSegmentPoints[1] = _points[newSegment[1]].clone();
			return _lineSegments.push(newSegment)-1;
			
		}
		
		/**
		 * Frame event handler 
		 * @param event
		 * 
		 */		
		private function frame( event:Event ):void
		{
//			if ( _index == 0 )
//			{
//				_count++ ;
//				_currentLineSegment = createNewLineSegment( ) ;
//			}
//			//	Take the vector defined by newSegment[1] - newSegment[0] 
//			//	and rotate it around the current axis every 50 frames
//			var t:Number = (_index++)/SEGMENT_LENGTH ;
//			_index %= SEGMENT_LENGTH ;
			
			//	Given a line segment, find a vector that's perpendicular to the segment
			var lineSegment:Vector.<int> = _lineSegments[_currentLineSegment] ;
			
//			//	First, find a random point that's not on the line segment
			var a:Vector3D = _points[lineSegment[0]] ;
			var b:Vector3D = _points[lineSegment[1]] ;
			
//			var p:Vector3D = b.subtract( a ) ;
//			p = p.crossProduct( _worldUp );
//			p.normalize() ;
//			
//			//	It'd be smarter to create these once per
//			//	line segment in the createNewLineSegment handler
//			var from:Quaternion = new Quaternion();
//			from.SetAxisAngle( _currentAxis, 0 );
//			var to:Quaternion = new Quaternion();
//			to.SetAxisAngle( _currentAxis, Math.PI / 4);
//			
//			//	Interpolate using slerp
//			var quaternion:Quaternion = Quaternion.Slerp( from, to, t );
//			
//			//	Create a quaternion from this vector, and transform it
//			//	by the interpolated quaterion (should refactor this into a function)
//			//	Here's a problem though.  If we modify the endpoint of the line
//			//	segment, we're going to end up interpolating a modified point.
//			//	We don't want to do this, so we should create a duplicate of the
//			//	current segment's enpoint and store it somewhere
//			var vector:Quaternion = new Quaternion( 0, p.x, p.y, p.z );
//			var inverse:Quaternion = quaternion.Inverse();
//			var product:Quaternion = vector.Multiply( inverse ) ;
//			product = quaternion.Multiply( product ) ;
//			p = new Vector3D( product.x, product.y, product.z );
//			p.scaleBy( SEGMENT_LENGTH );
//			_camera.position = p.add( a );
			
			
			
			var worldToView:Matrix4x4 = _camera.lookAt( new Vector3D( a.x, a.y, a.z, 1), _worldUp ) ;//_camera.transform;_ ; //_camera.lookAt( new Vector3D(0,300,0), Vector3D.Z_AXIS ) ;
			var projection:Matrix4x4 = _camera.perspective ;
			var screenTransform:Matrix4x4 = _camera.getScreenTransformMatrix( ) ;
			
			//	Keep a collection of points we're transforming
			var transformedPoints:Vector.<Vector3D> = new Vector.<Vector3D>( );
			
			//	Iterate over all the line segments
			for ( var j:int = 0; j < _lineSegments.length; j++ )
			{
				//	Grab the current line segment
				lineSegment = _lineSegments[j] ;
				a = _points[lineSegment[0]].clone() ;
				b = _points[lineSegment[1]].clone() ;
				a = worldToView.transform( a ) ;
				b = worldToView.transform( b ) ;
				
				//	Clip the line segment a-b
				var clip:Vector.<Vector3D> = _camera.clip( a, b ) ;
				if ( clip != null )
				{
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
			for ( j = 0; j < transformedPoints.length; j+= 2 )
			{
				a = transformedPoints[j] ;
				b = transformedPoints[j+1] ;
				graphics.lineStyle( 1, 0x000000 ) ;
				graphics.moveTo( a.x, a.y );
				graphics.lineTo( b.x, b.y ) ;
				graphics.lineStyle( undefined ) ;
				graphics.beginFill( 0xff0000 );
				graphics.drawCircle( a.x, a.y, 1 ) ;
				graphics.drawCircle( b.x, b.y, 1 ) ;
				graphics.endFill() ;
			}
		}
	}
}