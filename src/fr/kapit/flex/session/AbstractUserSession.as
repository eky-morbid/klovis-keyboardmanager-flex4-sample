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
	
	[Bindable]
	public class AbstractUserSession implements IUserSession
	{
		
		//------------------------------------------------------------------------
		//
		//  Private Properties
		//
		//------------------------------------------------------------------------
		private var otherInfo:HashMap = new HashMap();
		
		
		
		public function AbstractUserSession(abstractEnforcer:AbstractUserSession)
		{
			if (this != abstractEnforcer)
				throw new Error("Abstract class instanciation error");
		}
		
		//------------------------------------------------------------------------
		//
		//  Implementation : IUserSesion
		//
		//------------------------------------------------------------------------
		
		private var _name:String;
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		private var _id:String;
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function getPropertyValue(propertyName:String):*
		{
			return otherInfo.getElement(propertyName);
		}
		
		public function setProperty(propertyName:String, value:*):void
		{
			otherInfo.put(propertyName, value);
		}
	}
}