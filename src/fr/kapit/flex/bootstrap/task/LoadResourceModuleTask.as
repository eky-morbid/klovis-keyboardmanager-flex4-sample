////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.bootstrap.task
{
	import com.adobe.cairngorm.task.Task;
	
	import flash.events.IEventDispatcher;
	
	import mx.events.ResourceEvent;
	import mx.resources.ResourceManager;
	
	/**
     * Task that loads a Resource Module 
     */
	public class LoadResourceModuleTask extends Task
	{
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		
		private var loader:IEventDispatcher;
		
		//------------------------------------------------------------------------
		//
		//  Public properties
		//
		//------------------------------------------------------------------------
		
		//-------------------------------
		//  Simple bindables
		//-------------------------------
		
		[Bindable]
		public var url:String;
		
		//------------------------------------------------------------------------
		//
		//  Implementation : Task
		//
		//------------------------------------------------------------------------
		
		override protected function performTask():void
		{
			if (url == null)
				fault();
			
			loader = ResourceManager.getInstance().loadResourceModule(url);
			loader.addEventListener(ResourceEvent.COMPLETE, onLoadingComplete);
			loader.addEventListener(ResourceEvent.ERROR, onLoadingError);
		}
		
		//------------------------------------------------------------------------
		//
		//  Event listeners
		//
		//------------------------------------------------------------------------
		
		private function onLoadingComplete(event:ResourceEvent):void
		{
			cleanUp();
			complete();
		}
		
		private function onLoadingError(event:ResourceEvent):void
		{
			cleanUp();
			fault();
		}
		
		private function cleanUp():void
		{
			loader.removeEventListener(ResourceEvent.COMPLETE, onLoadingComplete);
			loader.removeEventListener(ResourceEvent.ERROR, onLoadingError);
			loader = null;
		}
	}
}