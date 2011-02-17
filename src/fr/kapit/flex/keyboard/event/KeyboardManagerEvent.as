////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.keyboard.event
{
	import flash.events.Event;

	public class KeyboardManagerEvent extends Event
	{
		public static const KEY_BOARD_MANAGER_EVENT:String = "KEY_BOARD_MANAGER_EVENT";
		
		private var _keyCombination:String;
		
		public function KeyboardManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, keyCombination:String=null)
		{
			super(type, bubbles, cancelable);
			_keyCombination = keyCombination;
		}
		
		public function get keyCombination():String
		{
			return _keyCombination;
		}
		
		override public function clone():Event
		{
			return new KeyboardManagerEvent(type, bubbles, cancelable, _keyCombination);
		}
	}
}