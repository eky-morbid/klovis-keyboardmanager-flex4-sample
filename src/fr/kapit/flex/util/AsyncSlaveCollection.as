////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.util
{
	import mx.collections.ArrayCollection;

	public class AsyncSlaveCollection extends SlaveCollection
	{
		public function AsyncSlaveCollection(master:AsyncCollection, deepCloning:Boolean=false)
		{
			super(master, deepCloning);
		}
		
		public function get async():AsyncCollection 
		{
			return master as AsyncCollection;
		}
		
		override public function get length():int 
		{
			if (!async.isLoaded) 
				return async.length
			else
				return super.length
		}
		
		override public function getItemAt(index:int, prefetch:int=0):Object 
		{
			if (!async.isLoaded)
				return async.getItemAt(index, prefetch);
			else
				return super.getItemAt(index, prefetch);
		}
	}
}