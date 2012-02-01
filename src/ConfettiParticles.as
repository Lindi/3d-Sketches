package
{
	import _3d.Camera;
	
	import flash.display.GraphicsPathWinding;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import math.Matrix4x4;
	
	[SWF(backgroundColor='#ffffff')]
	public class ConfettiParticles extends Sprite
	{
		private var _confetti:Vector.<Confetti> = new Vector.<Confetti>();
		private var _camera:Camera ;
		private var _index:int ;
		private static const RADIANS:Number = Math.PI / 180 ;
		private static const COSINE_RADIANS:Number = Math.cos( RADIANS ) ;
		private static const SINE_RADIANS:Number = Math.sin( RADIANS ) ;
		
		
		public function ConfettiParticles()
		{
			super();
			
			//	Make some confetti
			var particles:Number = 150 ;
			for ( var i:int = 0; i < particles; i++ )
			{
				var confetti:Confetti = new Confetti( );
				confetti.scale = 20 ;
				confetti.position = new Vector3D( );
				setPosition( confetti );
				color( confetti ) ;
				confetti.velocity = Math.random();
				_confetti.push( confetti ) ;
			}
			
			//	Make a new camera
			_camera = new Camera( );
			_camera.position = new Vector3D( );
			_camera.position.x = 0 ;//+ int( Math.random() * 200 ) ;
			_camera.position.y = 0;//-100 + int( Math.random() * 200 ) ;
			_camera.position.z = 500;//100 + int( Math.random() * 200 ) ;
			_camera.position.w = 1 ;
			_camera.width = 400 ;
			_camera.height = 400 ;
			_camera.setPerspective( 50, _camera.width/_camera.height, 20, 1000 ) ; 
			_camera.getScreenTransformMatrix( stage.stageWidth, stage.stageHeight ) ;
			
			
			//	Add a frame event listener for drawing
			addEventListener( Event.ENTER_FRAME, frame ) ;
		}
		
		/**
		 * Capture the frame event and draw the confetti 
		 * @param event
		 * 
		 */		
		private function frame( event:Event ):void
		{
			//	Create a list for z-sorting
			var sort:Array = new Array();
			var worldUp:Vector3D = Vector3D.Y_AXIS.clone();
			worldUp.negate() ;
			
			//	Use the camera to move the camera up and down
			//	in the y direction
			var n:Number = 100 ;
			var y:Number = Math.abs( n - ( _index++ % ( 2 * n + 1 )));
			_index %= int.MAX_VALUE ;
			
			
			var angle:Number = 1 * RADIANS ;
			var x:Number = _camera.position.x ;
			var z:Number = _camera.position.z ;
			_camera.position.x = COSINE_RADIANS * x - SINE_RADIANS * z;
			_camera.position.z = COSINE_RADIANS * z + SINE_RADIANS * x;
			_camera.position.y = y ;
			_camera.position.w = 1 ;
			
			
			//	Iterate over the confetti and compute their projections
	 		var worldToView:Matrix4x4 = _camera.lookAt( new Vector3D( 0, 150, 0, 1), worldUp ) ;//_camera.transform;_ ; //_camera.lookAt( new Vector3D(0,300,0), Vector3D.Z_AXIS ) ;
			var projection:Matrix4x4 = _camera.perspective ;
			var screenTransform:Matrix4x4 = _camera.getScreenTransformMatrix( ) ;
			for ( var i:int = 0; i < _confetti.length; i++)
			{
				//	Grab a reference to the automaton
				var confetti:Confetti = _confetti[ i ]  ;
				x = confetti.position.x ;
				z = confetti.position.z ;
				var velocity:int = int( confetti.velocity * 2 );
				confetti.position.x = confetti.COSINE_OMEGA * x - confetti.SINE_OMEGA * z;
				confetti.position.z = confetti.COSINE_OMEGA * z + confetti.SINE_OMEGA * x;
				confetti.position.y -= confetti.velocity ;
				if ( confetti.position.y < 0 )
				{
					setPosition( confetti ) ;
					color( confetti ) ;
				}
				//	Cull the confetti that's not inside the view frustum
				var position:Vector3D = worldToView.transform( confetti.position );
//				if ( !_camera.test( position ))
//					continue ;
				
				
				//	Draw the confetti
				var localToWorld:Matrix4x4 = confetti.localToWorldTransform ;
				var vertices:Vector.<Vector3D> = confetti.vertices ;
				confetti.rotate( vertices ) ;
				
				var cull:Boolean = false ;
				for ( var j:int = 0; j < vertices.length; j++ )
				{
					vertices[ j ] = localToWorld.transform( vertices[ j]);
					vertices[ j ] = worldToView.transform( vertices[ j] ) ;
					if (( cull = !_camera.test( vertices[ j] )))
						break ;
					vertices[ j ] = projection.transform( vertices[ j] );
					vertices[ j ].project();
					vertices[ j ].w = 1 ;
					vertices[ j ] = screenTransform.transform( vertices[ j] ) ;
//					//if ( j == 0 )
//						trace( j, vertices[j] );
					z = vertices[j].z ;
				}
				if ( !cull )
					sort.push( { z: z, vertices: vertices, color: confetti.color } );
			}
			
			//sort.sort(foo);
			
			graphics.clear();
			for each ( var object:Object in sort )
			{
				vertices = object.vertices as Vector.<Vector3D> ;
				draw( vertices, object.color  ) ;
			}
		}
		
		private function setPosition( confetti:Confetti ):void
		{
			confetti.position.x = -10 + int( Math.random() * 20 ) ;
			confetti.position.y = 100 + int( Math.random() * 200 ) ;
			confetti.position.z = -10 + int( Math.random() * 20 ) ;
			confetti.position.w = 1 ;
		}
		
		/**
		 * Color the confetti 
		 * @param confetti
		 * 
		 */		
		private function color( confetti:Confetti ):void
		{
//			//	Dr. Candy
//			var color:int = int( Math.random() * 6 );
//			confetti.color = 
//				( color == 0 ? 0xFFFD00 : 
//					( color == 1 ? 0x43FF0C : 
//						( color == 2 ? 0x0093FF :
//							( color == 3 ? 0xF7008D :
//								( color == 4 ? 0xff0000 : 0x991596 )))));
			
//			//	New Year's Champagne
//			var color:int = int( Math.random() * 5 );
//			confetti.color = 
//				( color == 0 ? 0x97982E : 
//					( color == 1 ? 0x2A2A24 : 
//						( color == 2 ? 0xB2BDBD :
//							( color == 3 ? 0xCDCEB0 : 0x000000 ))));
			
			//	Pink Confetti (Luli)
			var color:int = int( Math.random() * 4 );
			confetti.color = 
				( color == 0 ? 0xBCBBA5 : 
					( color == 1 ? 0xFF86A6 : 
						( color == 2 ? 0xFFD8D9 : 0xFFF2ED )));
			
//			//	Marc Jacobs
//			var color:int = int( Math.random() * 4 );
//			confetti.color = 
//				( color == 0 ? 0xF21B6A : 
//					( color == 1 ? 0x41C0F2 : 
//						( color == 2 ? 0x027353 : 0xD9CB04 )));

			//			//	Winter
//			var color:int = int( Math.random() * 5 );
//			confetti.color = 
//				( color == 0 ? 0x292929 : 
//					( color == 1 ? 0x5B7876 : 
//						( color == 2 ? 0x8F9E8B :
//							( color == 3 ? 0xF2E6B6 : 0x600A0D ))));

//			//	Obama Hope
//			var color:int = int( Math.random() * 5 );
//			confetti.color = 
//				( color == 0 ? 0xD71A21 : 
//					( color == 1 ? 0xA61F38: 
//						( color == 2 ? 0x024059 :
//							( color == 3 ? 0x7CA4AE : 0xF2D6A2 ))));
		}
		
		/**
		 * Draw the confetti!
		 * 
		 */		
		private function draw( vertices:Vector.<Vector3D>, color:Number ):void
		{
			//graphics.lineStyle(.5);
			
			var commands:Vector.<int> = new Vector.<int>(5,true);
			commands[0] = 1 ;
			
			for ( var i:int = 1; i < 5; i++ )
				commands[ i] = 2;//( i % 2 ) + 1 ;
			
			var a:Vector3D = vertices[ 0 ] ;	
			var b:Vector3D = vertices[ 2 ] ;
			var c:Vector3D = vertices[ 3 ] ;
			var d:Vector3D = vertices[ 1 ] ;
			var coordinates:Vector.<Number> = new Vector.<Number>(10,true);
			
			i = 0 ;
			for each ( var vector:Vector3D in [a,b,c,d,a] )
			{
				coordinates[ i++ ] = vector.x ;
				coordinates[ i++ ] = vector.y ;
			}
			
			graphics.beginFill( color, .9 );	
			graphics.drawPath( commands, coordinates, GraphicsPathWinding.NON_ZERO );
			graphics.endFill();
			
		}
		/**
		 * Depth sorting function 
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		private function foo( a:Object, b:Object ):int
		{
			if ( a.z > b.z )
				return -1 ;
			if ( a.z < b.z )
				return 1 ;
			return 0 ;
		}

		

	}
}