////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
 package fr.kapit.flex.bootstrap.preloader
{
	import com.adobe.cairngorm.task.ITaskGroup;
	import com.adobe.cairngorm.task.TaskEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.events.FlexEvent;
	import mx.preloaders.IPreloaderDisplay;
	
	/**
	 * An abstract prelaoder that is built on the Cairngorm Task library.
	 * It allows to track visually the loading of Tasks when bootstraping an application
	 * 
	 * @includeExample PreloaderExample.mxml
	 * @includeExample DemoPreloader.as
	 * @includeExample PreloadTasks.mxml
	 * */
	public class AbstractPreloader extends Sprite implements IPreloaderDisplay
	{
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		private var bootsrapper:ITaskGroup;
		
		
		public function AbstractPreloader(bootstrapper:ITaskGroup=null)
		{
			this.bootsrapper = bootstrapper; 
			super();
		}
		
		//------------------------------------------------------------------------
		//
		//  Implementation : IPreloaderDisplay
		//
		//------------------------------------------------------------------------
		
		// Define a Loader control to load the SWF file.
		
		public function set preloader(preloader:Sprite):void
		{
			preloader.addEventListener(ProgressEvent.PROGRESS, frameworkProgressHandler);
			preloader.addEventListener(Event.COMPLETE, handleComplete);
			
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, frameworkCompleteHandler);
		}
		
		/**
		 * Create and addChild progress bar ui elements in this function.
		 **/ 
		public function initialize():void
		{
			throw new Error("You must override abstract initialize function"); 
		}
		
		public function get backgroundAlpha():Number
		{
			return 0;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
		}
		
		public function get backgroundColor():uint
		{
			return 0;
		}
		
		public function set backgroundColor(value:uint):void
		{
		}
		
		public function get backgroundImage():Object
		{
			return null;
		}
		
		public function set backgroundImage(value:Object):void
		{
		}
		
		public function get backgroundSize():String
		{
			return null;
		}
		
		public function set backgroundSize(value:String):void
		{
		}
		
		public function get stageWidth():Number
		{
			return _stageWidth;
		}
		
		private var _stageWidth:Number;
		
		public function set stageWidth(value:Number):void
		{
			
			_stageWidth = value;
		}
		
		private var _stageHeight:Number;
		
		public function get stageHeight():Number
		{
			return _stageHeight;
		}
		
		public function set stageHeight(value:Number):void
		{
			_stageHeight = value;
		}
		
		protected function get taskNumber():int
		{
			if (bootsrapper && bootsrapper.children)
				return bootsrapper.children.length;
			else
				return 0;
		}
		
		//------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//------------------------------------------------------------------------
		
		/**
		 * Method that tracks the loading of the framework.
		 * Usually, you override this method in sublasses of AbstractPreloader
		 * 
		 * @event contains info about the framework loading
		 **/
		protected function frameworkProgressHandler(event:ProgressEvent):void
		{
		}
		
		/**
		 * Method called once the framework is loaded.
		 * Usually, you override this method in sublasses of AbstractPreloader 
		 * 
		 * @event
		 **/
		protected function handleComplete(event:Event):void
		{
		}
		
		private function frameworkCompleteHandler(event:Event):void
		{
			if (bootsrapper)
			{
				bootsrapper.addEventListener(TaskEvent.CHILD_START, bootsrapper_childStartHandler);
				bootsrapper.addEventListener(TaskEvent.TASK_PROGRESS, bootsrapper_taskProgressHandler);
				bootsrapper.addEventListener(TaskEvent.TASK_COMPLETE, bootsrapper_taskCompleteHandler);
				bootsrapper.addEventListener(TaskEvent.TASK_FAULT, bootstrapper_taskFaultHandler);
				bootsrapper.start();
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Method called everytime a new task child is starting
		 * Usually, you override this method in sublasses of AbstractPreloader 
		 * 
		 * @event info about the current task to be exectuted 
		 **/
		protected function bootsrapper_childStartHandler(event:TaskEvent):void
		{
			
		}
		
		/**
		 * Method that tracks the progress of the current task
		 * Usually, you override this method in sublasses of AbstractPreloader 
		 * 
		 * @event info about the currest task executed 
		 **/
		protected function bootsrapper_taskProgressHandler(event:TaskEvent):void
		{
		}
		
		/**
		 * Method called when a task fails
		 * Usually, you override this method in sublasses of AbstractPreloader 
		 * 
		 * @event info about the currest task executed 
		 **/
		protected function bootstrapper_taskFaultHandler(event:TaskEvent):void
		{
		}
		
		private function bootsrapper_taskCompleteHandler(event:TaskEvent):void
		{
			cleanUpBootstrapper();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function cleanUpBootstrapper():void
		{
			bootsrapper.removeEventListener(TaskEvent.CHILD_START, bootsrapper_childStartHandler);
			bootsrapper.removeEventListener(TaskEvent.TASK_PROGRESS, bootsrapper_taskProgressHandler);
			bootsrapper.removeEventListener(TaskEvent.TASK_COMPLETE, bootsrapper_taskCompleteHandler);
			bootsrapper = null;
		}
		
	}
}