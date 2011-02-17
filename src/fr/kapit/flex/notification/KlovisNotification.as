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
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 * Abstract implementation of IKlovisNotification, that needs only to be extended with doSend() method implemented. 
	 * 
	 * This Notification class implements the following features:
	 * <li>Fluent api for remote command invocation: new MyNotification(params,..).send().resultTo(function)...</li>
	 * <li>Optional limitation of the number of simultaneous queries by type of notification</li>
	 * <li>Callback mechanism for result and fault, very practical and easy to use</li>
	 * <li>Custom data that will be passed to result and fault</li>
	 * <li>Automatic time measurement of the duration of the remote call</li> 
	 * This class will be extended by all implementors that wish to integrate the Klovis remote operation system into their own or favourite framework.<br/>
	 * To use this notification, you will use the following syntax:<br/>
	 * <code>
	 * new MyNotification(params,..).send().resultTo(function).faultTo(function).withData(data).usingFilteringContext(anObject).fromCommand(aResponder)
	 * </code>
	 * This is called a fluent api, as you are able to chain different calls one after another<br/>
	 * Of course, these calls are all optional, and you can chain as many responders as you want.
	 * 
	 */
	public class KlovisNotification extends flash.events.Event implements IKlovisNotification
	{
		protected var _name:String;
		protected var _parameters:Object; 
		protected var _startTime:int;
		protected var _endTime:int;
		protected var _data:Object;
		protected var _filteringContext:Object; 
		protected var _resultEvent:ResultEvent;
		protected var _faultEvent:FaultEvent;
		protected var _frameworkSendData:Array;
		protected var _command:IResponder;
		
		[ArrayElementType("Function")]
		private var _callbacks:Array = [];
		
		[ArrayElementType("Function")]
		private var _faults:Array = [];
		
		private var _retries : int = 0 ;
		
		// Static arrays
		private static var _chainedNotificationsByType:Object = {};
		private static var _runningNotificationsByType:Object = {};
		private static var _runningRestrictions:Object = {};
		private static var _retriesByType:Object = {} ;
		private static var _faultHandlersByType:Object = {} ;
		
		/**
		 * This attributes sets the number of retries whenever an operation has failed. Defaults to zero
		 */
		public var maxRetries : int = 0 ;
		
		/**
		 * Constructor.
		 * 
		 * @param name the name of the Notification
		 * @param params the parameters of the operation
		 * @param filteringContext any optional object used as a result filtering context
		 * @param maxRetries defines the maximum number of retries for the operation if it fails on first time
		 */
		public function KlovisNotification(name:String, params:Object, filteringContext:Object=null, maxRetries:int = 0)
		{
			//MemoryLeakWatcher.getInstance().addLeakWatch("KlovisNotification",this);
			super(name) ;
			_name = name;
			_parameters = params;
			_filteringContext = filteringContext;
			this.maxRetries = maxRetries ;
			initRestrictions();
		}
		
		/**
		 * Cleans the notification, reset all references, removes all callbacks.
		 */
		public function dispose() : void {
			_parameters = null ; 
			_data = null ;
			_filteringContext = null ; 
			_resultEvent = null ;
			_faultEvent = null ;
			_frameworkSendData = null ;
			_command = null ;
			 _callbacks = null ;
			_faults = null ;
		}		
		
		/**
		 * Place holder method to define initial restrictions on running count for operations.
		 * 
		 * Override this method if you want to define restrictions, using the static method addRunRestriction<br/>
		 * Restrictions are defined in term of max running operations for a given notification name (corresponding to a remote operation)
		 * 
		 * @see addRunRestriction
		 */
		protected function initRestrictions():void
		{
			
		}
		
		/**
		 * Returns the name of the notification.
		 * 
		 * Depending on actual implementation, the name may be a PureMVC notification name, or a Cairngorm event name, or a AS3 event type.
		 */
		public function get name():String 
		{
			return _name;
		}

		/**
		 * Parameters that will be passed to the operation.
		 * 
		 * Depending on actual transport mechanism, it will be either an Array (RPC, SOAP), or an Object (HTTP)
		 */		
		public function get parameters():Object
		{
			return _parameters;
		}
		
		/**
		 * Actual start time of the operation, when it is launched.
		 */
		public function get startTime():int
		{
			return _startTime;
		}
		
		/**
		 * End time of the operation, either through result or fault
		 */
		public function get endTime():int
		{
			return _endTime;
		}
		
		/**
		 * Elapsed operation time in ms.
		 */
		public function get elapsed():int
		{
			return _endTime - _startTime;
		}
		
		/**
		 * Specific and optional data not used in the remote call, but that will be retrieved upon result of the operation.
		 */
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void	
		{
			_data = value;
		}

		/**
		 * Specific and optional data that will be used as a filtering context for responses.
		 * 
		 * Depending on the implementation, it will be mapped onto existing attributes, such as the "type" for PureMVC notifications
		 * 
		 * @see usingFilteringContext
		 */
		public function get filteringContext():Object
		{
			return _filteringContext;
		}
		
		public function set filteringContext(value:Object):void
		{
			_filteringContext = value;
		}
		
		/**
		 * Result event of the operation, if succesfull.
		 */		
		public function get resultEvent():ResultEvent
		{
			return _resultEvent;
		}

		/**
		 * Fault event of the operation, if a fault occured.
		 */		
		public function get faultEvent():FaultEvent
		{
			return _faultEvent;
		}
		
		/**
		 * result data of the operation if successfull
		 */
		public function get resultData():Object
		{
			return _resultEvent ? _resultEvent.result:null;
		}
		
		/**
		 * Adds a run restriction for a notification
		 * 
		 * @param notifName the name(type) of the targetted notification
		 * @param max maximum allowed simultaneous runs for this operation type 
		 */
		public static function addRunRestriction(notifName:String, max:int):void
		{
			_runningRestrictions[notifName] = max;
		}
		
		/**
		 * Adds a retry count restriction for a given notification.
		 * 
		 * @param notifName name of the notification
		 * @param maxRetry number of retries allowed for this notification when fault occurs
		 * 
		 * Note that if maxRetries at been defined at instance level, it will be used first.<br/>
		 * If no maxRetries for a particular instance has been defined, then the global value for this notification type will be used.
		 */
		public static function addRetryRestriction(notifName:String, maxRetry:int) : void {
			_retriesByType[notifName] = maxRetry ;
		}
		
		public static function addFaultHandler(notifName:String, f:Function) : void {
			var handlers : Array = _faultHandlersByType[notifName] as Array ;
			if ( !handlers) {
				handlers = [] ;
				_faultHandlersByType[notifName] = handlers ;
			}
			if ( handlers.indexOf(f) < 0 ) 
				handlers.push(f) ;
		}
		
		public static function removeGlobalFaultHandler(notifName:String, f:Function) : Boolean {
			var handlers : Array = _faultHandlersByType[notifName] as Array ;
			if ( handlers ) {
				var index : int = handlers.indexOf(f) ;
				if (index >= 0) {
					handlers.splice(index,1) ;
					return true ;
				}
			}
			return false ;
		}
		
		/**
		 * Defines a filtering context for the operation.
		 * 
		 * @param value any object, that will be stored in the notification and retrieved later on during the response (result or fault)
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * @see filteringContext
		 */		
		public function usingFilteringContext(value:Object):IKlovisNotification
		{
			_filteringContext = value;
			return this;	
		}

		/**
		 * Defines optional data not used in the notification, but that is to be retrieved on response.
		 * 
		 * @param value any data to store in the notification
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged)
		 * 
		 * @see data
		 */		
		public function withData(value:Object):IKlovisNotification
		{
			_data = value;
			return this;	
		}		
		
		/**
		 * Adds a result callback to the operation.
		 * 
		 * The result callback has three different signatures, depending on what you need to retrieve.<br/>
		 * To retrieve only the decoded result data of the operation, the signature is:<br/>
		 * <code>
		 * function callback(value:TypeOfTheObjectReturnedByTheOperation):void 
		 * </code>
		 * To retrieve the Notification itself, with all its data inside:<br/>
		 * <code>
		 * function callback(note:IKlovisNotification)
		 * </code>
		 * And finally retrieve the ResultEvent only:<br/>
		 * <code>
		 * function callback(event:ResultEvent)
		 * </code>
		 * @param callback a function object with one of the above signatures
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * 
		 * @see ResultEvent
		 */		
		public function resultTo(f:Function):IKlovisNotification 
		{
			_callbacks.push(f);
			return this;
		}


		/**
		 * Adds a fault callback to the operation.
		 * 
		 * The fault callback has two different signatures, depending on what you need to retrieve.<br/>
		 * To retrieve the FaultEvent directly, the signature is:<br/>
		 * <code>
		 * function callback(value:FaultEvent):void 
		 * </code>
		 * To retrieve the Notification itself, with all its data inside, including the FaultEvent:<br/>
		 * <code>
		 * function callback(note:IKlovisNotification)
		 * </code>
		 * 
		 * @param callback a function object with one of the above signatures
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * 
		 * @see FaultEvent
		 */		
		public function faultTo(f:Function):IKlovisNotification 
		{
			_faults.push(f);
			return this;
		}		
		
		/**
		 * Run the operation mapped onto the notification.
		 * 
		 * @params args any additional parameters that could be needed by the implementor in order to dispatch the notification into the system.
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged)
		 
		 * For example, for PureMVC, the arguments will contain the facade needed to dispatch the notification<br/> 
		 * Note that the arguments here should not be used to pass remote operation parameters, that should be stored in the parameters attribute<br/>
		 */
		public function send(...args):IKlovisNotification 
		{
			var chainedNotifs:Array = chainedNotifications;
			_frameworkSendData = args;
			if (chainedNotifs.indexOf(this) < 0) 
			{
				chainedNotifications.push(this);
				processNext();
			}
			return this;
		}

		/**
		 * Defines an optional responding object, that will be called first before all callbacks.
		 * 
		 * @param value an IResponder object, for example, a Command for Cairngorm implementations
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * 
		 * @see IResponder
		 */		
		public function fromCommand(value:IResponder):IKlovisNotification 
		{
			_command = value;
			return this;
		}		
		
		/**
		 * Implements the actual send call to the remote service.
		 * 
		 * This method will be specific to every framework into which KlovisNotification is integrated.<br/>
		 * For instance, for PureMVC, it will call facade.notifyObservers(this), while for Cairngorm 2 it will be CairngormEventDispatcher.dispatchEvent(this)
		 */
		protected function doSend():IKlovisNotification 
		{
			return this;
		}
		
		/**
		 * Operation responder.
		 */
		public function result(value:Object):void 
		{
			_endTime = getTimer();
			removeRunningNotification();
			_resultEvent = value as ResultEvent; 
			
			if (_command )
				_command.result(value);
				
			for each (var f:Function in _callbacks) 
			{
				try 
				{
					f(_resultEvent.result); // f(resultData)
				} 
				catch (e:TypeError) 
				{ 
					try 
					{
						f(this); // f(KlovisNotification)
					} 
					catch (e2:TypeError) 
					{ 
						f(value); // f(resultEvent)
					}
				} 
			}
			processNext();			
		}
		
		/**
		 * Operation fault.
		 */
		public function fault(value:Object):void
		{
			_endTime = getTimer();
			removeRunningNotification();
			var localMaxRetries : int ;
			localMaxRetries = this.maxRetries ;

			if ( localMaxRetries == 0 )
				localMaxRetries = _getRetriesCount(name) ;
			
			if ( _retries == localMaxRetries ) {
				var handlers : Array = _getFaultHandlers(name) ;
				for each (var faultHandler:Function in handlers) {
					try{
						faultHandler(this);
					} 
					catch (e:TypeError){
						faultHandler(value);
					}
				}
			}			
			
			if (_retries < localMaxRetries) {
				_retries++ ;
				_send(true) ;
			}
			
			_faultEvent = value as FaultEvent;
			
			for each (var f:Function in _faults) 
			{
				try {
					f(this);
				} 
				catch (e:TypeError)	{
					f(value);
				}
			}
			processNext();			
		}		
		
		private function get runningNotifications():Array 
		{
			var notifs:Array = _runningNotificationsByType[_name];
			if (notifs == null) 
			{
				notifs = [];
				_runningNotificationsByType[_name] = notifs;
			}			
			return notifs;
		}
		
		
		// Private methods
		
		private function _send(retry:Boolean=false):IKlovisNotification 
		{
			_startTime = getTimer();
			if (retry)
				runningNotifications.splice(0,0,this)
			else
				runningNotifications.push(this);
			doSend();
			return this;			
		}			
		
		private function get chainedNotifications():Array 
		{
			var notifs:Array = _chainedNotificationsByType[_name];
			if (notifs == null) 
			{
				notifs = [];
				_chainedNotificationsByType[_name] = notifs;
			}			
			return notifs;
		}		
		
		private function processNext():void 
		{
			var max :int = getMaxRunningAllowed(_name);
			while ((max == 0 || runningNotifications.length < max) && chainedNotifications.length>0) 
			{
				var note:KlovisNotification = chainedNotifications.shift() ;
				note._send();
			}
		}
		
		private function removeRunningNotification():void 
		{
			for (var i:int = 0; i<runningNotifications.length;i++) 
			{
				if (runningNotifications[i] == this) 
				{
					runningNotifications.splice(i,1);
					break;
				}
			}
		}		
		
		private function getMaxRunningAllowed(notifName:String):int 
		{
			var result : int ;
			if ( _runningRestrictions.hasOwnProperty("*") )
				result = _runningRestrictions["*"] ;
			else 
				result = _runningRestrictions[notifName] as int;
			return result ;
		}		
		
		private function _getRetriesCount(name:String) : int {
			if ( _retriesByType.hasOwnProperty(name))
				return int(_retriesByType[name]) ;
			else if ( _retriesByType.hasOwnProperty("*"))
				return int(_retriesByType["*"]) ;
			return 0 ;			
		}
		
		private function _getFaultHandlers(name:String) : Array {
			var result : Array = _faultHandlersByType[name] as Array ;
			if ( !result )
				result = _faultHandlersByType["*"] as Array ;
			return result
		}
	}
}