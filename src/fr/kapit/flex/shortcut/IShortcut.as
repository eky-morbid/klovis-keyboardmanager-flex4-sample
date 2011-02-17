////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.shortcut
{
	public interface IShortcut
	{
		/**
		 * Specifies the mapping between the shortcut letter and 
		 * the event name.
		 * Return an Array of Shortcut type object 
		 *
		 */ 
		function get shortcutMapping():Array
		/**
	     *  @private
	     */
		function set shortcutMapping(value:Array):void
		
		/**
		 * Hold the new format of the label after specifying
		 * the underlined letter. 
		 *
		 */ 
		function get labelUnderlined():String
		/**
	     *  @private
	     */
		function set labelUnderlined(value:String):void
		/**
		 * Specifies if the component having this shortcut is of higher
		 * priority. 
		 */ 
		function get globalShortcuts():Boolean
		/**
	     *  @private
	     */
		function set globalShortcuts(value:Boolean):void
	}
}