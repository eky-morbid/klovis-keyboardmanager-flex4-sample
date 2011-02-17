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
	import mx.core.UIComponent;
	/**
	 * Is responsable of generating a label with an underlined letter
	 * representing the selected shortcut letter.
	 */ 
	public class ShortcutHelper
	{
		//------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//------------------------------------------------------------------------
		/**
		 * Decode the label and serach for ~ character. If this character is 
		 * found a new label is generated.
		 * 
		 * @param label
		 * @param the component
		 * @return the shortcut letter
		 */ 
		public static function decodeLabel(label:String, control:IShortcut):String 
		{
			var shortcutLetter:String;
			if (!label)
				return null;
				
			var pos : int = label.indexOf("~")
			// If ~ is found and is not the last character then decode and modify string
			if ( pos >= 0 && pos != label.length - 1 ) 
			{
				shortcutLetter = label.charAt(pos+1)
				// If ~ is at first position, just get the remaining string
				if ( pos == 0 ) 
				{
					control.labelUnderlined =  "<u>" + shortcutLetter +"</u>" + label.substr(pos+2)
				} 
				else 
				{ 
					control.labelUnderlined = label.substr(0,pos) + "<u>" + shortcutLetter +"</u>"
					if ( pos + 1 < label.length - 1 ) // If the shortcut is NOT the last character
					 control.labelUnderlined += label.substr(pos+2) 
				}
			} 
			else 
			{ // else keep original label
				control.labelUnderlined = label
			}
			return shortcutLetter;
		}
	}
}