////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.login
{
	import fr.kapit.actionscript.collections.maps.PersistentMap;

	/**
	 * This class stores/restores a login/password from the Local Hard Drive 
	 * Values are not encrypted so don't use this class to store sensitive credentials
	 * 	 
	 * @includExample Login.mxml
	 **/ 
	public class LocalCredentials
	{
		//------------------------------------------------------------------------
		//
		//  Private properties
		//
		//------------------------------------------------------------------------
		private var cookie:PersistentMap;
		
		//------------------------------------------------------------------------
		//
		//  Properties
		//
		//------------------------------------------------------------------------
		
		//-------------------------------
		//  login
		//-------------------------------
		
		public function get login():String
		{
			return cookie.getElement("login") as String;
		}
		
		//-------------------------------
		//  password
		//-------------------------------
		
		public function get password():String
		{
			return cookie.getElement("password") as String;
		}
		
		//-------------------------------
		//  cookieName
		//-------------------------------
		
		/** cookie identifier **/
		private var _cookieName:String;
		
		public function set cookieName(value:String):void
		{
			_cookieName = value;
			loadCookie();
		}
		
		
		
		public function LocalCredentials(cookieName:String=null)
		{
			if (cookieName)
			{
				_cookieName = cookieName;
				loadCookie();
			}
		}
		
		//------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//------------------------------------------------------------------------
		private function loadCookie():void
		{
			cookie = new PersistentMap(_cookieName);
			
			if (!cookie.hasKey("login"))
			{
				cookie.put("login", null);
				cookie.put("password", null);
			}
			
		}
		
		//------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//------------------------------------------------------------------------
		/**
		 * Save a login and a password string
		 * in a Shared Object
		 * 
		 * @param login
		 * @param password
		 **/
		public function save(login:String, password:String):void
		{
			cookie.put("login", login);
			cookie.put("password", password);
		}
		
		/**
		 * Clear the cookie
		 **/
		public function clear():void
		{
			cookie.clear();
		}
		
	}
}