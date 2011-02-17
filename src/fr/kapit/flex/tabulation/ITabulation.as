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
	public interface ITabulation
	{
		/**
		 * Specifies the id of the component that should take the focus once
		 * the tab button is pressed.
		 */ 
		function get nextTabId():String;
		/**
	     *  @private
	     */
		function set nextTabId(id:String):void;
	}
}