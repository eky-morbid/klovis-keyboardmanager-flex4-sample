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
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	/**
	 * This class defines all methods that will exist in a KlovisNotification.
	 * 
	 * Implementing this interface will allow you to hook this new kind of Notification onto an existing frameworks.<br/>
	 * KlovisNotification is an "all-in-the-box" Notification for running remote operations through event dispatch at framework level<br/>
	 * KlovisNotification provides you with:
	 * <li>a simple and fluent API</li>
	 * <li>a central point to hold all notification related processing</li>
	 * <li>a fluent api to add callbacks and faults callbacks on operations</li>
	 * <li>a simple query scheduler, with maximum queries allowed by notification type</li>
	 * <li>data storage in your notifications</li>
	 * <li>Automatic time and duration measurement</li>
	 * 
	 * Notice that the notification will also be a responder to the command.
	 */
	public interface IKlovisNotification extends IResponder
	{
		/**
		 * Returns the name of the notification.
		 * 
		 * Depending on actual implementation, the name may be a PureMVC notification name, or a Cairngorm event name, or a AS3 event type.
		 */
		function get name():String
		
		/**
		 * Parameters that will be passed to the operation.
		 * 
		 * Depending on actual transport mechanism, it will be either an Array (RPC, SOAP), or an Object (HTTP)
		 */
		function get parameters():Object
		
		/**
		 * Actual start time of the operation, when it is launched.
		 */
		function get startTime():int
		 
		/**
		 * End time of the operation, either through result or fault
		 */
		function get endTime():int
		
		/**
		 * Elapsed operation time in ms.
		 */
		function get elapsed():int
		
		/**
		 * Specific and optional data not used in the remote call, but that will be retrieved upon result of the operation.
		 */
		function get data():Object
		function set data(value:Object):void
		
		/**
		 * Specific and optional data that will be used as a filtering context for responses.
		 * 
		 * Depending on the implementation, it will be mapped onto existing attributes, such as the "type" for PureMVC notifications
		 * 
		 * @see usingFilteringContext
		 */
		function get filteringContext():Object
		function set filteringContext(value:Object):void
		
		/**
		 * Result event of the operation, if succesfull.
		 */
		function get resultEvent():ResultEvent
		
		/**
		 * Fault event of the operation, if a fault occured.
		 */
		function get faultEvent():FaultEvent;
		function get resultData():Object;
		
		//Methods
		/**
		 * Run the operation mapped onto the notification.
		 * 
		 * @params args any additional parameters that could be needed by the implementor in order to dispatch the notification into the system.
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged)
		 * 
		 * For example, for PureMVC, the arguments will contain the facade needed to dispatch the notification
		 */
		function send(...args):IKlovisNotification
		
		/**
		 * Defines a filtering context for the operation.
		 * 
		 * @param value any object, that will be stored in the notification and retrieved later on during the response (result or fault)
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * @see filteringContext
		 */
		function usingFilteringContext(value:Object):IKlovisNotification
		
		/**
		 * Defines an optional responding object, that will be called first before all callbacks.
		 * 
		 * @param value an IResponder object, for example, a Command for Cairngorm implementations
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged) 
		 * 
		 * @see IResponder
		 */
		function fromCommand(value:IResponder):IKlovisNotification
		
		/**
		 * Defines optional data not used in the notification, but that is to be retrieved on response.
		 * 
		 * @param value any data to store in the notification
		 * @return itself, so that chaining calls in a fluent way is possible (and encouraged)
		 * 
		 * @see data
		 */
		function withData(value:Object):IKlovisNotification	
		
		/**
		 * Adds a result callback to the operation.
		 * 
		 * The result callback has three different signatures, depending on what you need to retrieve.<br/>
		 * To retrieve only the decoded result data of the operation, the signature is:<br/>
		 * <code>
		 * function callback(value:TypeOfTheObjectReturnedByTheOperation) : void 
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
		function resultTo(callback:Function):IKlovisNotification
		
		/**
		 * Adds a fault callback to the operation.
		 * 
		 * The fault callback has two different signatures, depending on what you need to retrieve.<br/>
		 * To retrieve the FaultEvent directly, the signature is:<br/>
		 * <code>
		 * function callback(value:FaultEvent) : void 
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
		function faultTo(f:Function):IKlovisNotification
	}
}
