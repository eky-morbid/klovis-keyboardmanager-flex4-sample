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
	
	public interface IAppSession extends IAdditionalInfo
	{
		/**
		 * Utilisateur de la session
		 **/
		function set userSession(value:IUserSession):void;
		function get userSession():IUserSession;
		
	}
}