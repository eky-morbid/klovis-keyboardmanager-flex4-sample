////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.shortcut
{
	public class Shortcut
	{
		public var shortcut:String;
		public var eventName:String;
		public var data:Object;
		
		public function Shortcut(shortcut:String=null, eventName:String=null, data:Object=null)
		{
			this.shortcut = shortcut;
			this.eventName = eventName;
			this.data = data;
		}

	}
}