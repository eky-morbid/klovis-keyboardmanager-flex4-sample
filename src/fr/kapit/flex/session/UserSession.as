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
	[Bindable]
	public class UserSession extends AbstractUserSession
	{
		
		public function UserSession()
		{
			super(this);
		}
		//------------------------------------------------------------------------
		//
		//  Public Properties
		//
		//------------------------------------------------------------------------
		public var lastConnexion:Date;
		
		public var token:String;
		
		public var logged:Boolean;
		
	}
}