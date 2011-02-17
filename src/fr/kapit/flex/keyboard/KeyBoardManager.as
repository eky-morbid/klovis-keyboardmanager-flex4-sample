////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.keyboard
{
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	import fr.kapit.flex.keyboard.event.KeyboardManagerEvent;
	
	import mx.core.Application;
	/**
	 * The KeyBoardManager is responsible of detecting all the keys pressed
	 * on the keyboard and dispatches then a KeyBoardManagerEvent with the 
	 * corresponding key combination.
	 * */
	public class KeyBoardManager extends EventDispatcher
	{
		include "KeyboardSpecialKeys.inc";
		
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		
		/**
		 * Contains all the pressed keys
		 */ 
		private var _keyCodes:Array = new Array();
		
		//------------------------------------------------------------------------
		//
		//  Constructor
		//
		//------------------------------------------------------------------------
		
		public function KeyBoardManager()
		{
			if(Application.application)
			{
				// The event listeners are added on the systemManager because when an  
				// event is dispatched from a PopUp, this is the only place where we can get
				// catch it.
				Application.application.systemManager.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				Application.application.systemManager.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//------------------------------------------------------------------------
		
		/**
		 * Each time a key is pressed, this method is called to create a key
		 * combination seperated by the + character. For example: ctrl+a+b
		 */ 
		private function handleKeyPress():void
		{
			var concat:String = "";
			for each(var key:Number in _keyCodes)
			{
				if(specialkeys[key])
					concat = (concat == "") ? specialkeys[key] : concat + "+" + specialkeys[key];
				else	
					concat = (concat == "") ? String.fromCharCode(key).toLocaleLowerCase() :concat + "+" + String.fromCharCode(key).toLocaleLowerCase();
			}
			dispatchEvent(new KeyboardManagerEvent(KeyboardManagerEvent.KEY_BOARD_MANAGER_EVENT, false, false, concat));
		}
		
		//------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//------------------------------------------------------------------------
		
		/**
		 * When a key is pressed on the keyboard this method is called.
		 * @param event
		 */ 
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode != 13 && _keyCodes.indexOf(event.keyCode)<0) 
			{
				_keyCodes.push(event.keyCode);
				handleKeyPress();
			}
		}
		
		/**
		 * When a pressed key is released this function is called.
		 * @param event
		 */ 		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			if(_keyCodes.indexOf(event.keyCode)!=-1)
				_keyCodes.splice(_keyCodes.indexOf(event.keyCode),1);
		}
		
		

	}
}