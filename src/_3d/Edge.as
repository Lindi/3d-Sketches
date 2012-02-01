package _3d
{
	public class Edge {
		
		public var index:Array = new Array(2);
		public var visible:Boolean = true ;
		
		public function Edge( a:int, b:int ) {
			index[0] = a ;
			index[1] = b ;
		}
		public function toString():Object {
			return index.toString();
		}
		
		public function clone():Edge {
			return new Edge( index[0], index[1] );
		}
		public function valueOf():Object {			
			var val:int = 0 ;
			var tmp:uint ;
			var string:String = index.toString();
			while ( string.length ) {
				val = ( val << 4 ) + string.substr(0,1).charCodeAt(0);
				if ( Boolean(tmp = ( val & 0xf0000000 ))) {
					val = val ^ ( tmp >> 24 );
					val = val ^ tmp;
				}
				string = string.substr(1);
			}
			return new Number(val);
		}
	}
}