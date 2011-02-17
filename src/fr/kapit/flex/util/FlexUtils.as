////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package  fr.kapit.flex.util
{
	
	 
	import flash.display.InteractiveObject;
	
	/**
	 * Retrieved from
	 * http://hillelcoren.com/2008/11/10/flex-autocomplete-component-a-new-take-on-an-old-standard/
	 */
	public class FlexUtils
	{
		public static function isChildOf(object:InteractiveObject, parentObject:InteractiveObject):Boolean
		{
			if (!object || !parentObject)
			{
				return false;
			}
			
			if (object == parentObject)
			{
				return true;
			}
			
			while (object.parent != null)
			{
				object = object.parent;
				
				if (object == parentObject)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Tests if two objects are equal by using the <code>equals()</code> method if it is defined in <code>object1</code>.
		 * If the <code>equals()</code> is not defined, the standard '==' equality is used.
		 * 
		 * @param object1 the first object to be tested
		 * @param object2 the second object to be tested
		 * @return true if the two objects are equal
		 * 
		 */
		public static function isEqualTo(object1:*, object2:*):Boolean
		{
			if ((object1 is Object) && Object(object1).hasOwnProperty("equals"))
				return object1.equals(object2);
			return object1 == object2;
		}
	}
}