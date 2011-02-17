////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.tabulation
{
	import flash.external.ExternalInterface;
	
	import fr.kapit.flex.keyboard.KeyBoardManager;
	import fr.kapit.flex.keyboard.event.KeyboardManagerEvent;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	/**
	 * Responsible of setting a focus over a component.
	 */ 
	public class TabulationManager
	{
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		/**
		 * Instance holder
		 */ 
		private static var _tabulationManager:TabulationManager;
		
		private var _keyBoardManager:KeyBoardManager;
		
		private var nextTabComponent:UIComponent;
		
		private var _startup:Boolean = false;
		
		private var _applicationName:String;
		
		//------------------------------------------------------------------------
		//
		//  Constructor
		//
		//------------------------------------------------------------------------
		
		public function TabulationManager()
		{
			if(_tabulationManager)
			{
				throw new Error("Only one ShortcutManager instance should be instantiated" );
			}
			else
			{
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
		 * Set the focus on the next component. 
		 */ 
		private function setFocusOnObject():void
		{
			if (_startup)
			{
				ExternalInterface.call('function browserFocus()'+'{document.getElementById(\''+_applicationName+'\').focus();}'); 
			}
			nextTabComponent.setFocus();
			nextTabComponent.drawFocus(true);
		}
		
		//------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//------------------------------------------------------------------------
		
		public static function getInstance():TabulationManager
		{
			if (!_tabulationManager)
				_tabulationManager = new TabulationManager();
			return _tabulationManager;
		}
		
		/**
		 * Reponsible of finding the next component that should have the focus and
		 * to selected immediatly if the tab key was not pressed
		 * 
		 * @param the current focused component.
		 * @param is the tab key is pressed
		 */ 
		public function applyTabulation(object:UIComponent, isTab:Boolean=false):void
		{
			
			if (object is ITabulation)
			{
				var nextTabId:String = (object as ITabulation).nextTabId;
				if (nextTabId)
				{
					nextTabComponent = Application.application[nextTabId];
					if (nextTabComponent)
					{
						if (isTab)
							// if the tab key is pressed we call the callLater function because 
							// we want to wait the screen upDate to finish to apply the focus.
							nextTabComponent.callLater(setFocusOnObject);
						else
							// else we set the focus immediatly
							setFocusOnObject();
					}				
				}
			}
		}
		
		/**
		 * This function is used to set focus on an object.
		 * This function solves the problem of focus on the startup of the application. This
		 * solution is only compatible IE and Firefox.
		 * 
		 * @param the component that should have the focus
		 * @param onStartUp indicate if this function is called on the startUp of the 
		 * application
		 * @param applicationName
		 */ 
		public function setFocus(component:UIComponent, onStartUp:Boolean=false, applicationName:String=null):void
		{
			nextTabComponent = component;
			_startup = onStartUp;
			_applicationName = applicationName;
			component.callLater(setFocusOnObject);
		}
		
		//------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//------------------------------------------------------------------------
		/**
		 * if the tab key is pressed.
		 */ 
		private function keyboardManagerEventHandler(event:KeyboardManagerEvent):void
		{
			if (event.keyCombination == 'tab')
			{
				var objectWithFocus:UIComponent = Application.application.focusManager.getFocus() as UIComponent;
				applyTabulation(objectWithFocus, true);
				
			}
		}
		
	}
}