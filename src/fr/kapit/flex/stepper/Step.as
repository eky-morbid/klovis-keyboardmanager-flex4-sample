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
	
	public class Step
	{
		public var name:String;
		
		public var data:Object;
		
		public var label:String;
		
		public var enabled:Boolean = true;
		
		public var valid:Boolean;
	}
}