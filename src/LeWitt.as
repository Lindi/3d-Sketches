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
		private var _position:Vector3D ;
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
			_position = new Vector3D( 0, 0, -250, 1 );
			_camera = new Camera();
			_camera.position = new Vector3D( );
			_camera.position.x = _position.x ;
			_camera.position.y = _position.y ;
			_camera.position.z = _position.z ;
			_camera.position.w = _position.w ;
			_camera.width = stage.stageWidth ;
			_camera.height = stage.stageHeight ;
			_camera.setPerspective( 50, _camera.width/_camera.height, 40, 20000 ) ; 
			_camera.getScreenTransformMatrix( stage.stageWidth, stage.stageHeight ) ;
			
			//	Start by creating a line segment
			addEventListener( Event.ENTER_FRAME, frame ) ;
		}
		
		/**
		 * Creates a line segment 
		 * @return 
		 * 
		 */		
		private function createLineSegment( ):void
		{
			var axis:Vector3D ;
			while (( axis = pickAxis(int( Math.random() * 3 ))) == _currentAxis ) {} ;
			while (( _currentAxis = pickAxis(int( Math.random() * 3 ))) == axis ) {} ;
			axis = axis.clone();
			axis.scaleBy( SEGMENT_LENGTH );
			var point:Vector3D ;
			if ( _points.length == 0 )
			{
				_points.push( new Vector3D( 0,0,100,1)) ;
				point = _points[ _points.length - 1 ] ;
				_points.push( point.add( axis ));
				var lineSegment:Vector.<int> = new Vector.<int>(2,true);
				lineSegment[0] = _points.length - 2 ;
				lineSegment[1] = _points.length - 1 ;
				_lineSegments.push( lineSegment ) ;
			}
			_points.push( _points[ _points.length - 2 ].clone() );
			lineSegment = new Vector.<int>(2,true);
			lineSegment[0] = _points.length - 2 ;
			lineSegment[1] = _points.length - 1 ;
			_lineSegments.push( lineSegment ) ;
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
				if (_count++ > 500 ) 
					removeEventListener( Event.ENTER_FRAME, frame ) ;
				else createLineSegment( ) ;
			}
			//	Take the vector defined by newSegment[1] - newSegment[0] 
			//	and rotate it around the current axis every 50 frames
			var n:int = SEGMENT_LENGTH ;
			var t:Number = (_index++)/n ;
			_index %= (n+1) ;
			
			//	It'd be smarter to create these once per
			//	line segment in the createNewLineSegment handler
			var axis:Vector3D ;
//			if ( _count % 3 )
//			{
//				axis = _currentAxis.clone();
//				axis.negate();
//			} else
//			{
				axis = _currentAxis ;
//			}
			var from:Quaternion = new Quaternion();
			from.SetAxisAngle( axis, 0 );
			var to:Quaternion = new Quaternion();
			to.SetAxisAngle( axis, Math.PI / 2 );
			
			//	Interpolate using slerp
			var quaternion:Quaternion = Quaternion.Slerp( from, to, t );
			
			//	Grab the points of the current line segment, and calculate
			//	the vector obtained by subtracting b from a
			var index:int = _lineSegments.length - 2 ;
			var a:Vector3D = _points[_lineSegments[index][1]] ;
			var b:Vector3D = _points[_lineSegments[index][0]] ;
			var d:Vector3D = b.subtract( a ) ;
			
			//	Create a quaternion from this vector, and transform it
			//	by the interpolated quaterion (should refactor this into a function)
			//	Here's a problem though.  If we modify the endpoint of the line
			//	segment, we're going to end up interpolating a modified point.
			//	We don't want to do this, so we should create a duplicate of the
			//	current segment's enpoint and store it somewhere
			
			//	Note that we can also call the rotate method of the
			//	quaternion to do the same thing
			var vector:Quaternion = new Quaternion( 0, d.x, d.y, d.z );
			var inverse:Quaternion = quaternion.Inverse();
			var product:Quaternion = vector.Multiply( inverse ) ;
			product = quaternion.Multiply( product ) ;
			
			
			//	Create
			//	Modify the current segment
			a = _points[_lineSegments[index][1]] ;
			b = a.add( new Vector3D( product.x, product.y, product.z ) );
			var c:Vector3D =  _points[_lineSegments[index+1][1]];
			c.x = b.x ;
			c.y = b.y ;
			c.z = b.z ;
			c.w = 1 ;
			
			//	Rotate the camera around the current point
			var angle:Number = 5 * RADIANS ;
			var x:Number = _position.x ;
			var z:Number = _position.z ;
			_position.x = COSINE_RADIANS * x - SINE_RADIANS * z;
			_position.z = COSINE_RADIANS * z + SINE_RADIANS * x;
			_position.w = 1 ;
			_camera.position.x = _position.x + c.x ;
			_camera.position.y = _position.y ;
			_camera.position.z = _position.z + c.z ;
			_camera.position.w = 1 ;
			
			//	Create the world up vector 
			//	Make sure that when it's crossed with the direction vector
			//	the project is the y-vector
			_worldUp = new Vector3D( -_position.z, 0, _position.x ) ;
			_worldUp.normalize() ;
			
			//	Create the transformation matrices
			var worldToView:Matrix4x4 = _camera.lookAt( new Vector3D( c.x, c.y, c.z, 1), _worldUp ) ; 
			var projection:Matrix4x4 = _camera.perspective ;
			var screenTransform:Matrix4x4 = _camera.getScreenTransformMatrix( ) ;
			
			//	Keep a collection of points we're transforming
			var transformedPoints:Vector.<Vector3D> = new Vector.<Vector3D>( );
			for ( var j:int = 0; j < _points.length; j++ )
			{
				transformedPoints.push( worldToView.transform( _points[j] )) ;
			}
			
			//	Copy the line segments too
			var transformedLineSegments:Vector.<Vector.<int>> = new Vector.<Vector.<int>>( );
			for ( j = 0; j < _lineSegments.length; j++ )
			{
				var lineSegment:Vector.<int> = new Vector.<int>(2,true);
				lineSegment[0] = _lineSegments[j][0] ;
				lineSegment[1] = _lineSegments[j][1] ;
				transformedLineSegments.push( lineSegment ) ;
			}
			
			//	Make a look up table that keeps track of which
			//	points have been transformed so we don't transform
			//	duplicate points
			var lut:Vector.<int> = new Vector.<int>( transformedPoints.length * 2, true ) ;
			for ( j = 0; j < lut.length; j++ ) lut[j] = -1 ;
			
			//	Iterate over all the line segments
			for ( j = 0; j < transformedLineSegments.length; j++ )
			{
				//	Grab the current line segment
				lineSegment = transformedLineSegments[j] ;
				
				//	Grab the current line segment which has already
				//	been transformed to view space
				a = transformedPoints[lineSegment[0]] ;
				b = transformedPoints[lineSegment[1]] ;
								
				//	Clip the line segment a-b
				var clip:Vector.<Vector3D> = _camera.clip( a, b ) ;
				if ( clip != null )
				{
					//	If we haven't mapped the segment endpoint yet ...
					if ( lut[lineSegment[0]] == -1 )
					{
						//	And the point was clipped ...
						if ( a != clip[0] )
						{
							//	Map the current line segment's starting index to a new integer
							//	which is the position of the newly clipped point in the array of
							//	transformed points
							lut[lineSegment[0]] = lineSegment[0] = transformedPoints.push( a ) - 1 ;
						} else
						{
							//	Otherwise, map the start index of the line segment to the same point
							lut[lineSegment[0]] = lineSegment[0] ;
						}						
					}
						
					//	If we haven't mapped the segment endpoint yet ...
					if ( lut[lineSegment[1]] == -1 )
					{
						//	And the point was clipped ...
						if ( b != clip[1] )
						{
							//	Map the current line segment's ending index to a new integer
							//	which is the position of the newly clipped point in the array of
							//	transformed points
							lut[lineSegment[1]] = lineSegment[1] = transformedPoints.push( b ) - 1 ;
						} else
						{
							//	Otherwise, map the end index of the line segment to the same point
							lut[lineSegment[1]] = lineSegment[1] ;
						}						
					}
				} else {
					lineSegment[0] = -1;
					lineSegment[1] = -1;
				}
			}
			
			//	We're doing extra work here.  We have to come up
			//	with a better data structure for this ...
			for ( j = 0; j < lut.length; j++ )
			{
				var i:int = lut[j] ;
				if ( i == -1 )
					continue ;
				a = transformedPoints[i] ;
				a = projection.transform( a );
				a.project();
				a.w = 1 ;
				a = screenTransform.transform( a ) ;
				transformedPoints[j].x = a.x ;
				transformedPoints[j].y = a.y ;
				transformedPoints[j].z = a.z ;
				transformedPoints[j].w = 1 ;
			}
			
			//	 Draw all the line segments
			//	The number of transformed points should always be even
			graphics.clear(); 
			graphics.lineStyle( undefined ) ;
			for ( j = 2; j < transformedLineSegments.length; j++ )
			{
				lineSegment = transformedLineSegments[j] ;
				if ( lineSegment[0] == -1 || lineSegment[1] == -1 )
					continue ;
				
				//	Grab the current line segment
				a = transformedPoints[lineSegment[0]] ;
				b = transformedPoints[lineSegment[1]] ;
				
				graphics.beginFill( 0xff0000 );
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