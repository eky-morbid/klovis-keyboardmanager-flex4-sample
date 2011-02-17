////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.session
{
	public interface IAdditionalInfo
	{
		/**
		 * Create a pair of property/value
		 * 
		 * @param propertyName property name
		 * @param value property's value
		 **/
		function setProperty(propertyName:String, value:*):void;
		
		/**
		 * Get a property's value
		 * 
		 * @param propertyName property name
		 * @return the property's value. null if the property doesn't exist 
		 **/ 
		function getPropertyValue(propertyName:String):*;
	}
}