////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.stepper.event
{
	import flash.events.Event;

	/**
	 *  The StepEvent class represents events that should dispatch
	 *  step UI components when their state changes
	 *  
	 */
	public class StepEvent extends Event
	{
		public static const STEP_NEXT:String = "stepNext";
		public static const STEP_PREVIOUS:String = "stepPrevious";
		public static const STEPS_TERMINATED:String = "stepsTerminated";
		public static const STEP_VALID_CHANGED:String = "stepValidChanged";
		public static const STEP_DISPLAYED:String = "stepDisplayed";
		
		private var _stepName:String;
		private var _valid:Boolean;
		private var _data:Object;
		
		public function StepEvent(type:String, stepName:String="", valid:Boolean=false, data:Object=null)
		{
			_stepName = stepName;
			_valid = valid;
			_data = data;
			super(type, true, cancelable);
		}
		
		public function get stepName():String
		{
			return _stepName;
		}
		
		public function get valid():Boolean
		{
			return _valid;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		override public function clone():Event
		{
			return new StepEvent(type, stepName, valid, data);
		}
		
	}
}