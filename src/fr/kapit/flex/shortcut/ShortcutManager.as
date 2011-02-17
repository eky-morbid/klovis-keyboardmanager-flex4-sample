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
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import fr.kapit.flex.keyboard.KeyBoardManager;
	import fr.kapit.flex.keyboard.event.KeyboardManagerEvent;
	import fr.kapit.flex.shortcut.event.ShortcutEvent;
	import fr.kapit.flex.tabulation.TabulationManager;
	
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.utils.UIDUtil;
	
	/**
	 * Responsible of dispatching the event associated to a shortcut
	 */ 
	public class ShortcutManager
	{
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		/**
		 * Instance holder
		 */
		private static var _shotcutManagerInstance:ShortcutManager;
		
		/**
		 * Contains all shortcuts and their associated events for all
		 * registered components.
		 */ 
		private var _shortcutDictionnary:Dictionary;
		
		private var _gloabalShortcut:Dictionary;
		
		private var _keyBoardManager:KeyBoardManager;
		
		//------------------------------------------------------------------------
		//
		//  Constructor
		//
		//------------------------------------------------------------------------
		
		public function ShortcutManager()
		{
			if(_shotcutManagerInstance)
			{
				throw new Error("Only one ShortcutManager instance should be instantiated" );
			}
			else
			{
				_shortcutDictionnary = new Dictionary(true);
				_gloabalShortcut = new Dictionary(true);
				_keyBoardManager = new KeyBoardManager();
				_keyBoardManager.addEventListener(KeyboardManagerEvent.KEY_BOARD_MANAGER_EVENT, keyboardManagerEventHandler);
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//------------------------------------------------------------------------
		
		/**
		 * The seacrh for the component associate with shortcut is done by testing 
		 * first of all the component with the focus and then all the childs of the 
		 * containers containing the component that have the focus. 
		 */ 
		private function searchForShortcut(uicomponent:UIComponent, shortcut:String):Boolean
		{
			var shortcuts:Array = _shortcutDictionnary[uicomponent];
			for each(var item:Shortcut in shortcuts)
			{
				if(item.shortcut.toLocaleLowerCase() == shortcut)
				{
					dispatchEvent(uicomponent, item);
					return true;
				}
			}
			
			return false;
		}
		
		private function searchForGloabalShortcut(shortcutKey:String):Boolean
		{
			for(var view:Object in _gloabalShortcut)
			{
				var shortcuts:Array = _gloabalShortcut[view];
				for each(var shortcut:Shortcut in shortcuts)
				{
					if(shortcut.shortcut == shortcutKey)
					{
						dispatchEvent(view as UIComponent, shortcut)
						return true;
					}
				} 
			}
			return false
		}
		
		private function dispatchEvent(view:UIComponent, shortcut:Shortcut):void
		{
			if(shortcut.eventName)
			{
				view.dispatchEvent(new ShortcutEvent(ShortcutEvent.SHORTCUT_EVENT, shortcut));
			}
			else
			{
				if(view is Button)
				{
					view.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
				else if(view is Label)
				{
					TabulationManager.getInstance().applyTabulation(view);
				}
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//------------------------------------------------------------------------
		
		public static function getInstance():ShortcutManager
		{
			if(!_shotcutManagerInstance )
			{
				_shotcutManagerInstance = new ShortcutManager();
			}
			return _shotcutManagerInstance;
		}
		
		/**
		 * Rgister the component and the correspondent shortcut mapping 
		 * 
		 * @param view the component that wants to subscribe
		 * @param shortcuts the shortcut mapping, must contain Shortcut object
		 */ 
		public function subscribe(view:UIComponent, shortcuts:Array):void
		{
			if(view is IShortcut)
			{
				if((view as IShortcut).globalShortcuts)
				{
					_gloabalShortcut[view] = shortcuts;
				}
				else
				{
					_shortcutDictionnary[view] = shortcuts;
				}
			}
		}
		
		/**
		 * Unrgister the component 
		 * 
		 * @param the component that wants to subscribe
		 */ 		
		public function unSubscribe(view:UIComponent):void
		{
			var UID:String = UIDUtil.getUID(view as Object);
			delete _shortcutDictionnary[UID];
		}
		
		//------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//------------------------------------------------------------------------
		
		private function keyboardManagerEventHandler(event:KeyboardManagerEvent):void
		{
			var shortcut:String = event.keyCombination;
			
			// Searching for global shortcut
			
			if(searchForGloabalShortcut(shortcut))
				return;
			
			// Searching for shortcut
			
			// Retrieve the component with the current focus
			var objectWithFocus:UIComponent = Application.application.focusManager.getFocus() as UIComponent;
			if(objectWithFocus)
			{
				var parentObject:UIComponent = objectWithFocus;
				var isShortcutFound:Boolean;
				var i:int;
				while(parentObject && parentObject != Application.application)
				{
					isShortcutFound = searchForShortcut(parentObject, shortcut);
					if(isShortcutFound)
					{
						return;
					}
					else
					{
						for(i=0; i<parentObject.numChildren; i++)
						{
							isShortcutFound = searchForShortcut(parentObject.getChildAt(i) as UIComponent, shortcut); 
							if(isShortcutFound)
								return;
						}
						parentObject = parentObject.owner as UIComponent
						if(parentObject == Application.application)
						{
							isShortcutFound = searchForShortcut(parentObject, shortcut);
							if(isShortcutFound)
							{
								return;
							}
							else
							{
								for(i=0; i<parentObject.numChildren; i++)
								{
									isShortcutFound = searchForShortcut(parentObject.getChildAt(i) as UIComponent, shortcut); 
									if(isShortcutFound)
										return;
								}
							}
						}
					}
				}
			}
		}
		
		public function reset():void
		{
			_shortcutDictionnary = new Dictionary(true);
			_gloabalShortcut = new Dictionary(true);
			_keyBoardManager.removeEventListener(KeyboardManagerEvent.KEY_BOARD_MANAGER_EVENT, keyboardManagerEventHandler);
			_keyBoardManager = new KeyBoardManager();
			_keyBoardManager.addEventListener(KeyboardManagerEvent.KEY_BOARD_MANAGER_EVENT, keyboardManagerEventHandler);
		}
	}
}