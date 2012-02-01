package
{
	import _3d.Camera;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import geometry.Quaternion;
	
	import math.Matrix4x4;
	import math.Utils;

	public class LeWitt extends Sprite
	{
		private var _lineSegments:Vector.<Vector.<int>> ;
		private var _points:Vector.<Vector3D> ;
		private var _currentLineSegment:int ;
		private var _currentLineSegmentPoints:Vector.<Vector3D> ;  
		private var _currentAxis:Vector3D ;
		private var _index:int ;
		private var _camera:Camera ;


		public function LeWitt()
		{
			super();
			
			//	Create a collection of points and line segments
			_points = new Vector.<Vector3D>();
			_currentLineSegmentPoints = new Vector.<Vector3D>(2,true);
			
			//	Make a new camera
			_camera = new Camera();
			_camera.position = new Vector3D( );
			_camera.position.x = 0 ;
			_camera.position.y = 0 ;
			_camera.position.z = 500 ;
			_camera.position.w = 1 ;
			_camera.width = 400 ;
			_camera.height = 400 ;
			_camera.setPerspective( 50, _camera.width/_camera.height, 20, 1000 ) ; 
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
		private function createLineSegment( ):int
		{
			var lineSegment:Vector.<int> = new Vector.<int>(2,true);
			var a:Vector3D = getRandomPoint( 100 );
			lineSegment[0] = _points.push(a) -1;
			var b:Vector3D = getRandomPoint( 100 );	
			b.normalize() ;
			b.scaleBy( 20 ) ;
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
				var c:Vector3D = getRandomPoint( 20 );
				if ( !Utils.IsZero( c.dotProduct( line )))
					return c ;
			}
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
			_currentAxis.normalize();
			
			//	Create a new line segment from the points of the current line segment
			var index:int = Math.floor( Math.random() * 2 );
			var newSegment:Vector.<int> = new Vector.<int>(2,true);
			newSegment[0] = lineSegment[index]; 
			newSegment[1] = _points.push( _points[lineSegment[(index + 1) % 2]]) -1 ; 
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
			if ( _index == 0 )
			{
				_currentSegment = createNewLineSegment( ) ;
			}
			//	Take the vector defined by newSegment[1] - newSegment[0] 
			//	and rotate it around the current axis every 50 frames
			var t:Number = (( _index++ % 50 )/50.0 );
			
			//	It'd be smarter to create these once per
			//	line segment in the createNewLineSegment handler
			var from:Quaternion = new Quaternion();
			from.SetAxisAngle( _currentAxis, 0 );
			var to:Quaternion = new Quaternion();
			to.SetAxisAngle( _currentAxis, Math.PI / 2 );
			
			//	Interpolate using slerp
			var quaternion:Quaternion = Quaternion.Slerp( from, to, t );
			
			//	Grab the points of the current line segment, and calculate
			//	the vector obtained by subtracting b from a
			var a:Vector3D = _currentLineSegmentPoints[0] ;
			var b:Vector3D = _currentLineSegmentPoints[1] ;
			var d:Vector3D = b.subtract( a ) ;
			d.normalize();
			
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
			var v:Vector3D = new Vector3D( product.x, product.y, product.z ) ;
			var w:Vector3D =  a.add( v.scaleBy( 20 ));
			var q:Vector3D = _points[_lineSegments[_currentLineSegment]][1] ;
			q.x = w.x ; q.y = w.y ; q.z = w.z ;
			
			//	Iterate over the confetti and compute their projections
			var worldUp:Vector3D = Vector3D.Y_AXIS.clone();
			worldUp.negate() ;
			var worldToView:Matrix4x4 = _camera.lookAt( new Vector3D( q.x, q.y, q.z, 1), worldUp ) ;//_camera.transform;_ ; //_camera.lookAt( new Vector3D(0,300,0), Vector3D.Z_AXIS ) ;
			var projection:Matrix4x4 = _camera.perspective ;
			var screenTransform:Matrix4x4 = _camera.getScreenTransformMatrix( ) ;
			
			//	Keep a collection of points we're transforming
			var transformedPoints:Vector.<Vector3D> = new Vector.<Vector3D>( );
			
			//	Iterate over all the line segments
			for ( var j:int = 0; j < _lineSegments.length; j++ )
			{
				//	Grab the current line segment
				var lineSegment:Vector.<int> = _lineSegments[j] ;
				a = _points[lineSegment[0]].clone() ;
				b = _points[lineSegment[1]].clone() ;
				a = worldToView.transform( a ) ;
				b = worldToView.transform( b ) ;
				
				//	Clip the line segment a-b
				var clip:Vector.<Vector3D> = _camera.clip( a, b ) ;
				if ( clip != null )
				{
					//	Add the transformed points to the collection
					//	of transformed points
					a = clip[0] ;
					transformedPoints.push( a ) ;
					b = clip[1] ;
					transformedPoints.push( b ) ;
					
					a = projection.transform( a );
					a.project();
					a.w = 1 ;
					a = screenTransform.transform( a ) ;
					b = projection.transform( b );
					b.project();
					b.w = 1 ;
					b = screenTransform.transform( b ) ;
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
				graphics.beginFill( 0x000000 ) ;
				graphics.drawCircle( a.x, a.y, 2 ) ;
				graphics.drawCircle( a.x, a.y, 2 ) ;
				graphics.endFill() ;
				graphics.lineStyle( 1, 0x000000 ) ;
				graphics.moveTo( a.x, a.y );
				graphics.lineTo( b.x, b.y ) ;
			}

			
			//	Now we need to create a new line segment from the old one
			//	How do we do that?  We take the cross product of the two points that define the line
			//	segment.  That vector represents the line between the two points.  
			//	Then, we find a random point that's not on that line segment; which is to say
			//	we find a random point whose dot product with the line is non-zero
			
			//	After that, we take the cross product of the two vectors defined by the
			//	three points we now have (the two points in the original line segment,
			//	plus the new point we've just found).  This vector is perpendicular to the original
			//	line segment, and is a valid axis of rotation
			
			//	Then, we rotate a copy of the original line segment around our axis of rotation
			
			//	... rinse and repeat
		}
	}
}