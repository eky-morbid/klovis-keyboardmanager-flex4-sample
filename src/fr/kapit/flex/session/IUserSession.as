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
	public interface IUserSession extends IAdditionalInfo
	{
		/**
		 * User name
		 **/ 
		function get name():String;
		function set name(value:String):void;
		
		/**
		 * User identifier
		 **/
		function get id():String;
		function set id(value:String):void;
		
			
	}
}