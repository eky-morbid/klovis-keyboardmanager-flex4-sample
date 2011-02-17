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
	import fr.kapit.actionscript.collections.maps.HashMap;

	public class AbstractApplicationSession implements IAppSession
	{
		public function AbstractApplicationSession(abstractEnforcer:AbstractApplicationSession)
		{
			if (this != abstractEnforcer)
				throw new Error("Can't instanciate an abstract class");
		}
		
		//------------------------------------------------------------------------
		//
		//  Implementation : IAppSesion
		//
		//------------------------------------------------------------------------
		private var _userSession:IUserSession;
		
		public function set userSession(value:IUserSession):void
		{
			_userSession = value;
		}
		
		public function get userSession():IUserSession
		{
			return _userSession;
		}
		
		private var otherInfo:HashMap = new HashMap();
		
		public function setProperty(propertyName:String, value:*):void
		{
			otherInfo.put(propertyName, value);
		}
		
		public function getPropertyValue(propertyName:String):*
		{
			return otherInfo.getElement(propertyName);
		}
	}
}