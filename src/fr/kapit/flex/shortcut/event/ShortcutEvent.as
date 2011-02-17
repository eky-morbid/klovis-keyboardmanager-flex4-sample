////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.shortcut.event
{
	import flash.events.Event;
	
	import fr.kapit.flex.shortcut.Shortcut;
	
	public class ShortcutEvent extends Event
	{
		public static const SHORTCUT_EVENT:String = "ShortcutEvent";
		
		private var _shortcut:Shortcut;
		
		public function ShortcutEvent(type:String, shortcut:Shortcut, bubbles:Boolean=false, cancelable:Boolean=false)
		{ 
			super(type, bubbles, cancelable)
			_shortcut = shortcut;
		}
		
		public function get shortcut():Shortcut
		{
			return _shortcut;
		}
		
		override public function clone():Event
		{
			return new ShortcutEvent(type, _shortcut, bubbles, cancelable);
		}

	}
}