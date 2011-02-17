////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.notification
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;	
	use namespace mx_internal;		
	
	/**
	 * Implementation of KlovisNotification for local simulation of remote calls.
	 * 
	 * This notification will simulate remote calls, by sending a ResultEvent when dispatchResult is called<br/>
	 * The internal listeners of the token will be called, including the Notification itself of course<br/>
	 * All callbacks will also be called, so this notification may be used for mocking services, for example<br/>
	 * 
	 * @includeExample UserPagedCollection.as
	 */
	public class KlovisLocalNotification extends KlovisNotification
	{
		private var _delay : int ;
		private var _resultData : Object ;
		/**
		 * Constructor.
		 * 
		 * @param result the result that event will dispatch
		 * @param delay the time between send and response, defaults to 100 ms
		 */ 
		public function KlovisLocalNotification(result:Object, delay:int=100)
		{
			super("KlovisLocalNotification",null);
			_resultData = result ;
			_delay = delay ;
		}

		/**
		 * Dispatch the result event containing data (resultData attribute).
		 * 
		 * The ResultEvent will be dispatched only after delay period elapsed<br/>
		 * 
		 * @return the notification itself
		 */		
		 override protected function doSend():IKlovisNotification {
			var token:AsyncToken = new AsyncToken() ;
			token.addResponder(this) ;
			var result : ResultEvent = ResultEvent.createEvent(_resultData,token) ;		
			var timeOutToken:uint = setTimeout(
				function ():void {
					clearTimeout(timeOutToken) ; 
					result.mx_internal::callTokenResponders()
				},
				_delay) ;
			return this ;
		}
	}
}