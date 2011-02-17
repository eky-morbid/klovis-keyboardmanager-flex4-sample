////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.stepper
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import fr.kapit.flex.stepper.event.StepEvent;
	
	import mx.collections.IList;
	
	/**
	 * The StepperController can be used to manage a navigate inside a collection of steps.
	 * You typically use this component when you have to manage a sequence of screens like wizards
	 * 
	 * @includeExample MyStepper.mxml
	 * @includeExample Content.mxml
	 * @includeExample Step1.mxml
	 * @includeExample Navigator.mxml
	 */
	public class StepperController extends EventDispatcher
	{
		//------------------------------------------------------------------------
		//
		//  Properties
		//
		//------------------------------------------------------------------------
		
		//----------------------------------
    	//  dataProvider
    	//---------------------------------- 
    	
    	/**
     	 * @private
     	 * Storage for dataProvider
     	 */
    	private var _dataProvider:IList /* of Step */
    	
    	/**
    	 * The data provider for this StepperController.
    	 * It should contains a list of Step 
    	 * 
    	 * @see #Step
    	 */ 
		public function set dataProvider(value:IList):void
		{
			_dataProvider = value;
			if (_dataProvider)
			{
				setSelectedIndex(0);
				dispatchEvent(new Event("dataProviderChanged"));
			}
		}
		
		
		[Bindable(event="dataProviderChanged")]
		public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		//----------------------------------
    	//  hasNext
    	//---------------------------------- 
    	private var _hasNext:Boolean;
    	private var _nextEnabledIndex:int;

		[Bindable(event="hasNextChanged")]    	
		
    	/**
    	 * If <code>true</code>, there is at least an existing 
    	 * enabled step after the selected one
    	 */ 
		public function get hasNext():Boolean
		{
			return _hasNext;
		}
		
		private function setHasNext():void
		{
			var hsNext:Boolean;
			
			hsNext = hasExistingEnabledNextStep();
			
			if (_selectedIndex >= _dataProvider.length-1)
					hsNext = false;
					
			hsNext = hsNext && currentStepIsValid();
					
			if (hsNext != _hasNext)
			{
				_hasNext = hsNext;
				dispatchEvent(new Event("hasNextChanged"));
			}
		} 
		
		//----------------------------------
    	//  hasPrevious
    	//---------------------------------- 
		private var _hasPrevious:Boolean;		
		private var _previousEnabledIndex:int;
		
		[Bindable(event="hasPreviousChanged")]
		
		/**
    	 * If <code>true</code>, there is at least an
    	 * existing enabled previous step 
    	 * before the selected one
    	 * 
    	 */ 		
		public function get hasPrevious():Boolean
		{
			return _hasPrevious;
		}
		
		private function setHasPrevious():void
		{
			var hsPrevious:Boolean;
			
			hsPrevious = hasExistingEnabledPreviousStep();
			
			if (_selectedIndex <= 0)
					hsPrevious = false;
					
			if (hsPrevious != _hasPrevious)
			{
				_hasPrevious = hsPrevious;
				dispatchEvent(new Event("hasPreviousChanged"));
			}
		} 
		
		//----------------------------------
    	//  hasTerminate
    	//---------------------------------- 
		private var _hasTerminate:Boolean;		
		
		[Bindable(event="hasTerminateChanged")]
		
		/**
    	 * <code>true</code> if all enabled steps 
    	 * are valid
    	 */ 		
		public function get hasTerminate():Boolean
		{
			return _hasTerminate;
		}
		
		private function setHasTerminate():void
		{
			var hsTerminate:Boolean = true;
			
			var step:Step;
			for (var i:int = 0; i < dataProvider.length; i++)
			{
				step = dataProvider.getItemAt(i) as Step;
				if (step.enabled && !step.valid)
					hsTerminate = false;
			}
					
			if (hsTerminate != _hasTerminate)
			{
				_hasTerminate = hsTerminate;
				dispatchEvent(new Event("hasTerminateChanged"));
			}
		} 
		
		
		//----------------------------------
    	//  selectedIndex
    	//---------------------------------- 
    	private var _selectedIndex:int;
    	
		[Bindable(event="selectedIndexChanged")]
		
		/**
		 * Returns the selected step index
		 **/ 
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		private function setSelectedIndex(value:int):void
		{
			_selectedIndex = value;
			selectedStep = _dataProvider[_selectedIndex];
			updateState();
			dispatchEvent(new Event("selectedIndexChanged"));
		}
		
		//--------------------------------
		//  selectedStep
		//--------------------------------
		private var _selectedStep:Step;
		
		private function set selectedStep(value:Step):void
		{
			_selectedStep = value;
			dispatchEvent(new Event("selectedStepChanged"));
		}
		
		
		
		//------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//------------------------------------------------------------------------
		
		/**
		 * Go to the next alavaible step
		 **/
		public function next():void
		{
			if (_hasNext)
			{
				setSelectedIndex(_nextEnabledIndex);
				dispatchEvent(new StepEvent(StepEvent.STEP_NEXT));
			}
		}
		
		/**
		 * Go to the previous alavaible step
		 **/
		public function previous():void
		{
			if (_hasPrevious)
			{
				setSelectedIndex(_previousEnabledIndex);
				dispatchEvent(new StepEvent(StepEvent.STEP_PREVIOUS));
			}
		}
		
		/**
		 * Dispatch an event that tells all steps have been
		 * validated
		 **/
		public function terminate():void
		{
			if (_hasTerminate)
				dispatchEvent(new StepEvent(StepEvent.STEPS_TERMINATED));
		}
		
		/**
		 * Update the state of the stepper 
		 **/
		public function updateState(e:Event=null):void
		{
			setHasNext();
			setHasPrevious();
			setHasTerminate();
		}
		
		/**
		 * Valid a step
		 * 
		 * @param stepName name of the step
		 * @param valid  
		 **/
		public function validStep(stepName:String, valid:Boolean):void
		{
			for each (var step:Step in dataProvider)
			{
				if (step.name == stepName)
				{
					step.valid = valid; 
					updateState();
				}
			}
		}
		
		/**
		 * Enable a step
		 * 
		 * @param stepName name of the step
		 * @param valid  
		 **/
		public function enableStep(stepName:String, enabled:Boolean):void
		{
			for each (var step:Step in dataProvider)
			{
				if (step.name == stepName)
				{
					step.enabled = enabled; 
					updateState();
				}
			}
		}
		
		/**
		 * Returns <code>true</code> if the step param is clickable
		 * 
		 * @param step
		 **/
		public function clickableStep(step:Step):Boolean
		{
			if (selectedStepIndexIsLower(dataProvider.getItemIndex(step)))
				return false;
				
			if (!step.enabled)
				return false;
				
			return true;
		}
		
		/**
		 * Go to a specific step
		 * 
		 * This method only verifies if the new selected step
		 * is enabled or not.
		 * It doesn't check the strategy used in clickableStep
		 * to determine if it's allowed or not to change step.
		 * 
		 **/ 
		public function goToStep(stepName:String):void
		{
			var step:Step;
			for (var idx:int = 0; idx < dataProvider.length; idx++)
			{
				step = dataProvider.getItemAt(idx) as Step;
				if (step.name==stepName)
				{
					if (step.enabled)
						setSelectedIndex(idx);
					return;
				}
					
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//------------------------------------------------------------------------
		
		private function currentStepIsValid():Boolean
		{
			return _selectedStep.valid;
		}
		
		private function selectedStepIndexIsLower(index:int):Boolean
		{
			return dataProvider.getItemIndex(_selectedStep) < index;
		}
		
		private function hasExistingEnabledNextStep():Boolean
		{
			var foundEnabledNextStep:Boolean;
			var index:int = _selectedIndex+1;
			
			while (foundEnabledNextStep==false &&  (index <= dataProvider.length-1))
			{
				var step:Step = dataProvider.getItemAt(index) as Step;
				if (step.enabled)
				{
					foundEnabledNextStep = true;
					_nextEnabledIndex = index;
				}
				else
				{
					index++;
				}
			}
			
			return foundEnabledNextStep;
		}
		
		
		private function hasExistingEnabledPreviousStep():Boolean
		{
			var foundEnabledPreviousStep:Boolean;
			var index:int = _selectedIndex-1;
			
			while (foundEnabledPreviousStep==false &&  (index >= 0))
			{
				var step:Step = dataProvider.getItemAt(index) as Step;
				if (step.enabled)
				{
					foundEnabledPreviousStep = true;
					_previousEnabledIndex = index;
				}
				else
				{
					index--;
				}
			}
			
			return foundEnabledPreviousStep;
		}

	}
}