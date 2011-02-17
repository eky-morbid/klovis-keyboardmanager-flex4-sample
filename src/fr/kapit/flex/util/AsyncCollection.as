////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
package fr.kapit.flex.util
{
	import fr.kapit.flex.notification.IKlovisNotification;
	
	import mx.collections.ArrayCollection;

	/**
	 * This "abstract" class implements an asynchronous collection, that is able to load itself from a server.
	 * 
	 * This collection is intended to be populated by a remote call, that is essentially asynchronous, and to mask this details to the developer that uses it<br/>
	 * This class is abstract because it must be extended, and the method <code>loadData()</code> needs to be implemented in order to call a remote operation<br/>
	 * Of course, it works with KlovisNotification, and supports the fluent api of IKlovisNotification<br/>
	 * When created, the AsyncCollection is empty and in the "not loaded" state, then when trying to access <code>length</code> property or to get an item, the collection will be loaded<br/>
	 * There are two different ways to retrieve and use data from the collection, always in asynchronous mode:
	 * <li>Either by binding it to a IListView, then loading will occur when the list will display, and it will be refreshed automatically after the collection is loaded</li>
	 * <li>Either by using the <code>forEach</code> or <code>doWith</code> methods</li>
	 * 
	 * Warning: do not try to use an AsyncCollection in a synchronous way, unless your are sure that it has been already loaded, otherwise the collection will be empty<br/>
	 * 
	 * @see fr.kapit.klovis.common.notification.IKlovisNotification
	 */
	public class AsyncCollection extends ArrayCollection
	{
		private var _isLoading:Boolean= false;
		private var _notificationInProgress:IKlovisNotification;
		private static var _lastNotification:IKlovisNotification;
		
		/**
		 * True if the collection has been loaded, false otherwise.
		 */
		public var isLoaded:Boolean = false;
		
		/**
		 * Constructor.
		 * 
		 * AsyncCollection is an abstract class and needs to be extended with <code>loadData()</code> method implemented.
		 */
		public function AsyncCollection(source:Array=null)
		{
			super(source);
		}
		
		/**
		 * Returns the length of the collection.
		 * 
		 * Note that length will be zero until the collection has been loaded.
		 */
		override public function get length():int 
		{
			if (isLoaded)
			{
				return super.length;
			}
			else 
			{
				loadData();
				return 0;
			}
		}
		
		/**
		 * Returns a slave collection depending on this collection.
		 * 
		 * Use this method to retrieve a cloned and synchronized collection, for sake of local sorting or filtering, for example.
		 * 
		 * @see SlaveCollection
		 */
		public function getSlaveCollection():AsyncSlaveCollection
		{
			return new AsyncSlaveCollection(this);
		}
		
		/**
		 * Returns the item at specified index.
		 * @param index index of the item to retrieve
		 * @return the object at index position in the collection, or null if the collection has not been loaded yet.
		 */
		override public function getItemAt(index:int, prefetch:int=0):Object 
		{
			if (isLoaded)
			{
				return super.getItemAt(index, prefetch);
			}
			else 
			{
				loadData();
				return null;
			}
		}
		
		/**
		 * Asynchronous iterator for the collection.
		 * 
		 * Use this method to iterate each item of the collection, being sure that it has been loaded.
		 * @param f the callback function that will be called for each item.
		 * @param data an optional data object that will be passed to the callback on every iteration.
		 * 
		 * The callback signature must be of the form:<br/>
		 * <code>
		 * function (item:MyCollectionObject, data:MyDataType=null)
		 * </code>
		 * 
		 * Note that even if you do not specify any data, the callback method must accept a data in its arguments.<br/>
		 * Example:<br/>
		 * <code>
		 * myCollection.forEach(
		 * 	function (item:Object):void {
		 * 		doSomething(item)
		 * 	} 
		 * );
		 * </code> 
		 */
		public function forEach(f:Function, data:Object=null):void 
		{
			if (isLoaded) 
			{
				_forEach(f,data)
			} 
			else 
			{
				loadData().resultTo(
					function (value:ArrayCollection):void 
					{
						try 
						{
							_forEach(f, data);
						} 
						catch (e:Error) 
						{
							e.message;
						}
					}
				)
			}
		}		
		
		/**
		 * Asynchronous accessor to the collection.
		 * 
		 * Use this method to retrieve the collection, being sure that it has been loaded, and do something with it.
		 * @param f the callback function that will be called for each item.
		 * @param data an optional data object that will be passed to the callback on every iteration.
		 * 
		 * The callback signature must be of the form:<br/>
		 * <code>
		 * function (item:MyCollectionObject, data:MyDataType=null)
		 * </code>
		 * 
		 * Note that even if you do not specify any data, the callback method must accept a data in its arguments.<br/>
		 * Example:<br/>
		 * <code>
		 * myCollection.doWith(
		 * 	function (collection:AsyncCollection) {
		 * 		for each (var item:Object in collection) {
		 * 			doSomething(item)
		 * 		}
		 * );
		 * </code>
		 */
		public function doWith(f:Function, data:Object=null):void 
		{
			if (isLoaded == true)
			{
				f(this, data);
			} 
			else 
			{
				var thisObject:AsyncCollection = this;
				loadData().resultTo(
					function (value:ArrayCollection):void 
					{
						f(thisObject,data);
					}
				)
			}
		}		

		/**
		 * Actually loads the collection from remote server, asynchronously.
		 * 
		 * Concrete extended classes of AsyncCollection must override this method, perform the remote call using IKlovisNotification and return the notification.
		 * @return the notification used for dispatching the remote call. 
		 */
		protected function loadMethod():IKlovisNotification 
		{
			return null;
		}
		
		/**
		 * @private
		 */
		private function onDataLoaded(result:Object):void 
		{
			if (result is Array || result is ArrayCollection) 
			{
				for each (var item:Object in result) 
				{
					addItem(item);
				}			
			}
			isLoaded = true;
			_isLoading = false;
			_notificationInProgress = null;
			_lastNotification = null;
		}
		
		/**
		 * @internal
		 */		
		private function loadData():IKlovisNotification 
		{
			if (!_isLoading)
			{
				_isLoading = true;
				_notificationInProgress = loadMethod().resultTo(onDataLoaded);
				_lastNotification = _notificationInProgress;
			}
			return _notificationInProgress;
		}
		
		/**
		 * @internal
		 */
		private function _forEach(f:Function, data:Object=null):void 
		{
			for each (var item :Object in this) 
			{
				f(item,data);
			}
		}
	}
}