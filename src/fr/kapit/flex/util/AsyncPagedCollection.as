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
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import fr.kapit.flex.notification.IKlovisNotification;
	import fr.kapit.flex.notification.KlovisLocalNotification;
	import fr.kapit.flex.util.pagedCollectionClasses.AsyncPagedCollectionEvent;
	import fr.kapit.flex.util.pagedCollectionClasses.Page;
	
	import mx.collections.ArrayCollection;
	import mx.controls.listClasses.ListBase;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	/**
	 * Event dispatched when the collection has been fully loaded, ie all items.
	 */
	[Event(name="collectionLoaded",type="fr.kapit.flex.util.pagedCollectionClasses.AsyncPagedCollectionEvent")]
	
	/**
	 * Event dispatched when a page has been loaded into the collection
	 */
	[Event(name="pageLoaded",type="fr.kapit.flex.util.pagedCollectionClasses.AsyncPagedCollectionEvent")]
	
	/**
	 * Event dispatched when length has been loaded 
	 */
	[Event(name="lengthLoaded",type="fr.kapit.flex.util.pagedCollectionClasses.AsyncPagedCollectionEvent")]

	/**
	 * This "abstract" class implements an asynchronous "paginated" collection, that is able to load itself from a server.
	 * 
	 * This collection is intended to be populated by a remote call, asynchronousy and automatically<br/>
	 * The remote service is supposed to be paginated, and must be able to:<br/>
	 * <li>Return the total length of the collection</li>
	 * <li>Return "pages" of items, based on pageNumber and pageLength</li>
	 * This class is abstract because it must be extended, and the methods <code>loadLength()</code> and <code>loadPage()</code> need to be implemented in order to call remote operations<br/>
	 * Also, you will have to implement decoder methods for retrieving length and items from server response<br/>
	 * It works with KlovisNotification, and supports the fluent api of IKlovisNotification<br/>
	 * When created, the AsyncPagedCollection is empty and its length is not known yet.<br/>
	 * The length will be loaded from server upon first access to length property, or to an item through <code>getItemAt()</code> method<br/>
	 * As these functions are synchrone, they will return respectively 0 and null when the length or the item are not loaded yet<br/>
	 * When these values will be fetched by the server, they will be stored in the collection, and binding events will be fired, sot that view will be refreshed<br/>
	 * There are two different ways to retrieve and use data from the collection, always in asynchronous mode:
	 * <li>Either by binding it to a IListView, then loading will occur when the list will display, and it will be refreshed automatically after the collection is loaded</li>
	 * <li>Either by using the <code>forEach</code> or <code>doWith</code> methods</li>
	 * 
	 * Warning: do not try to use an AsyncCollection in a synchronous way, unless your are sure that it has been already loaded, otherwise the collection will be empty<br/>
	 * 
	 * @see fr.kapit.klovis.common.notification.IKlovisNotification
	 * 
	 * @includeExample UserPagedCollection.as
	 * @includeExample EntityCollection.as
	 * @includeExample DepartmentsOfCompanyCollection.as  
	 */
	
	public class AsyncPagedCollection extends ArrayCollection implements IAsyncPagedCollection
	{
		
		/**
		 * Size of the pages that will be loaded, defaults to 10, may be also changed dynamically if needed.
		 */
		public var 	pageSize : int = 10 ;
		/**
		 * If true, and there are at least one control attached, then pageSize will be adjusted automatically to the higher count of visible items.
		 */
		public var autoPageSize : Boolean = true ;
		
		private var _isLengthLoaded : Boolean = false ;
		private var _isLoadingLength : Boolean = false ;
		private var _isLoadingItems : Boolean = false ;
		
		private var _notificationLengthInProgress : IKlovisNotification ;
		
		// The actual remote length
		protected var _length : int = 0
		
		private var _indexesToLoad : Array = [] ;
		private var _indexesToLoad2 : Array = [] ;
		private var _indexesCallBack : Object = {} ;
		private var _itemsLoading : Object = {} ;
		protected var _timeDelay : int = 50 ; // delay in ms in which we record indexes to load before merging them and sending requests
		protected var _accumulationDelay : int = 250 ;
		private var _timeOutToken : uint ;
		private var _lastIndexTime : int ;
		private var _notLoadedItemsCount : int ;
		private var _isDisposed : Boolean = false ;
		private var _isLoadingAllPages : Boolean = false ;
		
		[ArrayElementType("mx.controls.listClasses.ListBase")]
		private var _listControls : Array = [] ;
		
		
		/**
		 * Constructor.
		 */
		public function AsyncPagedCollection()
		{
			super();
			_indexesToLoad.sort(Array.NUMERIC) ;
			_indexesToLoad2.sort(Array.NUMERIC) ;
			
		}
		
		/**
		 * Call server method for loading collection length.
		 * @return a notification object corresponding to the server operation to call
		 * 
		 * Note:<b>this method must be implemented by concrete AsyncPagedCollection classes</b>
		 */
		public function loadLength() : IKlovisNotification {
			return null ;
		}
		
		public function get isLengthLoaded() : Boolean {
			return _isLengthLoaded ;
		}
		
		/**
		 * Returns the length of the collection from server result data.
		 * @param result the remote operation result, containing collection length
		 * @return collection length
		 * 
		 * Note:<b>this method must be implemented by concrete AsyncPagedCollection classes</b>
		 */
		public function getLengthFromResult(result:Object) : int {
			return -1 ;
		}
		
		/**
		 * Call server method for loading a page.
		 * @param page the Page object containing coordinates of the page to load.
		 * @return a notification object corresponding to the server operation to call
		 * With AsyncPagedCollection, the server will have to be able to process the fixed page mode, where pageIndex and pageLength are transmitted in the query<br/>
		 * 
		 * Note:<b>this method must be implemented by concrete AsyncPagedCollection classes</b>
		 */				
		public function loadPage(page:Page) : IKlovisNotification {
			return null ;
		}
		
		/**
		 * Returns the items of the collection from server result data.
		 * @param result the remote operation result, containing collection items
		 * @return collection items array
		 * 
		 * Note:<b>this method must be implemented by concrete AsyncPagedCollection classes</b>
		 */
		public function getItemsFromResult(result:Object) : Array {
			return null ;
		}
		
		/**
		 * Returns true if collection is 100% loaded, false otherwise.
		 */
		public function get isLoaded() : Boolean {
			return _notLoadedItemsCount == 0 ;
		}
		
		/**
		 * Increases the length by a given value.
		 * 
		 * This method should be use only to add potential places in the collection for new items.
		 * @param delta the size of the growth  
		 */
		public function grow(delta:uint) : void {
			_length += delta ;
		}
		
		/**
		 * Clear all elements, may be call when garbaging a collection, and only at this moment.
		 *
		 * Do not try to use a disposed collection, it will throw exceptions.
		 */
		public function dispose() : void {
			if ( _timeOutToken ) {
				clearInterval(_timeOutToken)
				_timeOutToken = 0 ;
			}
			_notificationLengthInProgress = null ;
			_indexesToLoad = null ;
			_indexesToLoad2 = null ;
			_indexesCallBack = null ,
			_itemsLoading = null ;
			_listControls = null ;
			_isDisposed = true ;
		}
		
		/**
		 * Attach a ListBase element to the collection, such as a List, a DataGrid for example, in order to filter items loaded to the visible portion of the list.
		 * 
		 * When using the collection as a dataProvider for a ListBase Flex control, if you scroll to the bottom of the list, then almost all indexes on the way will be retrieved from the collection<br/>
		 * If it has a very large number of elements, then the server will have to load lots of items, that may not be necessary if you do not see them displayed on the screen<br/>
		 * To avoid this behavious, you may filter the loaded items by attaching one or more ListBase controls, and only the items actually displayed will be loaded, which is much more efficient for large collections and scrolling users<br/>
		 * In this mode, you will still be able to load all elements, either through loadAll(), doWith() or forEach() methods<br/>
		 * @param value a ListBase inherited control, such as a List or a DataGrid.
		 * @return this for fluent api
		 */
		public function attachListControl(value:ListBase) : AsyncPagedCollection {
			if ( _listControls.indexOf(value) < 0 )
				_listControls.push(value)
			return this ;
		}
		
		/**
		 * Detach a ListBase control from the collection.
		 * @param value the control to detach
		 * @return this for fluent api
		 */
		public function detachListControl(value:ListBase) : AsyncPagedCollection {
			var idx:int =  _listControls.indexOf(value) ;
			if ( idx >= 0 )
				_listControls.splice(idx,1) ;
			return this ;
		}
		
		/**
		 * Returns the length of the collection.
		 * 
		 * If length has not yet been loaded from server and is now known at the moment, then it will be loaded asynchronusly through the loadLength() method (overloaded)<br/>
		 * @return zero if length has not been loaded yet, and remote collection length after loading
		 * 
		 * Do not use length synchrously unless you are sure that it has been loaded before. 
		 */
		override public function get length():int {
			if (!_isLengthLoaded) {
				try {
					_loadLength()
				} catch (e:Error) {
					
				}
			}		
			return _length;
		}
		
		
		/**
		 * Refresh the length of the collection, by reloading it from the server.
		 * @return the load length notification, on which you can add callbacks
		 */
		public function refreshLength() : IKlovisNotification {
			if ( !_isLoadingLength ) {
				_isLoadingLength = true ;
				_notificationLengthInProgress = loadLength().resultTo(
					function (length:int) : void {
						_length = length
					}
					).faultTo(_onLengthFailed) ;
			}
			return _notificationLengthInProgress ;
		}
		
		/**
		 * Asynchronous get length, using a callback.
		 * 
		 * To work with an unloaded collection, you need to use the set of asynchronous methods<br/>
		 * This method retrieves the length from server, if required, and sends it to your callback function.<br/>
		 * The callback signature is:<br/>
		 * <code>
		 * function f(length:int, data:Object) : void
		 * </code>
		 * @param f the callback with above signature
		 * @param data optional data, will be sent to your callback (even if not specified upon call)
		 */
		public function doWithLength(f:Function, data:Object=null) : void {
			if ( _isLengthLoaded )
				f(_isLengthLoaded, data) ;
			else {
				_loadLength().resultTo(
					function (resultData:Object) : void {
						f(getLengthFromResult(resultData),data) ;
					}
				);
			}
		}
		
		/**
		 * Returns the item at specified index.
		 * @param index index of the item to retrieve
		 * @return the object at index position in the collection, or null if this item has not been loaded yet.
		 * 
		 * Do not use this method synchronously unless you are sure that index has already been loaded, or you'll get a null instead
		 */
		override public function getItemAt(index:int,prefetch:int=0):Object {
			var isItemLoaded:Boolean ;
			var item:Object ;
			if ( !_isLengthLoaded) {
				_loadLength().resultTo(
					function (length:int) {
						getItemAt(index) ;
					}
				)
				return null ;
			}
			
			if ( index >= super.length )
				isItemLoaded = false ;
			else {
				item = super.getItemAt(index) ;
				isItemLoaded = (item != null) ;
			}
			if ( isItemLoaded ) {
				return item ;
			}
			else {
				_loadItemAt(index) ;
				return null ;
			}
		}	
		
		
		/**
		 * Adds an item in the collection, and increments length.
		 * @param item the item to add.
		 */
		override public function addItem(item:Object):void {
			super.addItem(item) ;
			_length++ ;
		}
		
		/**
		 * Asynchronous get item, using a callback.
		 * 
		 * To work with an unloaded collection, you need to use the set of asynchronous methods<br/>
		 * This method retrieves an item from server, if required, and sends it to your callback function.<br/>
		 * The callback signature is:<br/>
		 * <code>
		 * function f(item:<the type of your remote items>, data:Object) : void
		 * </code>
		 * @param f the callback with above signature
		 * @param data optional data, will be sent to your callback (even if not specified upon call)
		 */
		public function doWithItem(index:int, f:Function, data:Object=null) : void {
			if ( _isItemLoaded(index) )
				f(super.getItemAt(index),data) ;
			else {
				_loadItemAt(index, 
					function (idx:int) : void {
						var item:Object = getItemAt(index)
						f(item,data) ;
					}
				) ;
			}
		}
		
		/**
		 * Asynchronous iterator for the collection.
		 * 
		 * Use this method to iterate each item of the collection, being sure that it has been loaded.
		 * @param f the callback function that will be called for each item, must have signature: <code>function (iItem:int,item:Object,data:Object) : Boolean</code>
		 * @param data an optional data object that will be passed to the callback on every iteration.
		 * 
		 * The callback signature must be of the form:<br/>
		 * <code>
		 * function (index:int, item:MyCollectionObject, data:MyDataType=null) : Boolean
		 * </code>
		 * The callback will return true to continue the loop, false to break it<br/>
		 * Parameters are: index of the item in the collection, current item, optional data that you may have passed upon forEach call<br/> 
		 * Note that even if you do not specify any data, the callback method must accept a data in its arguments.<br/>
		 * Example:<br/>
		 * <code>
		 * myCollection.forEach(
		 * 	function (index:int,item:Object):void {
		 * 		doSomething(item)
		 * 	} 
		 * );
		 * </code> 
		 */
		public function forEach(f:Function, data:Object=null) : void{
			_forEach(f,data) ;
		}	
		
		/**
		 * Loads all pages, if required.
		 * 
		 * @return a notification that you can attach to
		 */
		public function loadAllPages() : IKlovisNotification {
			var note:KlovisLocalNotification = new KlovisLocalNotification(true) ;
			if ( isLoaded )
				note.send() ;
			else {
				_isLoadingAllPages = true ;
				// Listens to page complete
				addEventListener(AsyncPagedCollectionEvent.COLLECTION_LOADED_EVENT,
					function __collectionLoaded(event:Event) : void {
						removeEventListener(AsyncPagedCollectionEvent.COLLECTION_LOADED_EVENT, __collectionLoaded) ;
						note.send() ;
					} 
				) ;
				// Loops all items, will provoke all pages to be loaded
				for (var i:int = 0 ; i < _length ; i++) {
					getItemAt(i) ;
				}
			}
			return note ;
		}
		
		/**
		 * Asynchronous accessor to the collection.
		 * 
		 * Use this method to retrieve the collection, being sure that it has been loaded, and do something with it.
		 * @param f the callback function that will be called for each item, must be <code>function(item:AsyncPagedCollection, data:Object) : void</code>
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
		 * 	function (collection:ArrayCollection) {
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
				var thisObject:ArrayCollection = this;
				addEventListener(AsyncPagedCollectionEvent.COLLECTION_LOADED_EVENT,
					function __onLoaded(event:Event) : void {
						removeEventListener(AsyncPagedCollectionEvent.COLLECTION_LOADED_EVENT,__onLoaded) ;
						f(thisObject,data);
					}
				) ;
				loadAllPages() ;
			}
		}	
		
		/**
		 * This method will search an item with its id, loading pages as necessary.
		 * 
		 * @param id the identifier of the object to find out
		 * @param f the callback function to call when object is found, of form <code>function (foundIndex:int, foundItem:Object, data:Object) : void</code>
		 * @param idProperty the name of the attribute containing the id value to search for, defaults to "id"
		 * @param data optional data to pass back to the function
		 * 
		 * Notes: 
		 * <li>to call this method could provoke the load of the whole collection if the item is not found, or if it is at the end of the collection.</li>
		 * <li>if the item is not found then the callback will be called with index=-1 and item=null, so the callback must be able to handle these special values</li>
		 * 
		 */ 
		public function findById(id:Object, f:Function, idProperty:String = "id", data:Object=null) : void {
			var found : Boolean = false ;
			// First look into memory items, if present, should be fast
			for (var i:int = 0 ; i < _length ; i++) {
				if (_isItemLoaded(i)) {
					var item : Object = super.getItemAt(i) ;
					if (item["idProperty"] == id) {
						f(i,item,data) ;
						return ;
					}
				} 
			}
			// If not found, then iterate the collection
			forEach(
				function (index:int, item:Object,data:Object) : Boolean {
					if (item["idProperty"] == id) {
						found = true ;
					}
					if ( found ) {
						if ( index >= _length ) {
							var delta : int = index - length + 1 ;
							while (delta-- >0)
								addItem(null) ;
						}
						
						f(index, item, data)
						return false ; // break
					}
					if (index == _length-1 && !found) 
						f(-1,null,data) ;
					return true ;
				}
			) ;
		}
		
		/**
		 * @ignore
		 */
		public function getFillingMap() : Array {
			var start : int = 0 ;
			var end : int = -1 ;
			var filled:Boolean = false;
			var newfilled : Boolean = false ;
			var map:Array = []
			
			filled = _isItemLoaded(0) ;
			for (var i:int = 1 ; i < _length ; i++) {
				if ( _isItemLoaded(i) )
					newfilled = true ;
				else
					newfilled = false ;
				if ( newfilled != filled ) {
					map.push({start:start,end:i,filled:filled})
					filled = newfilled;
					start = i+1 ;
				}
			}
			map.push({start:start,end:i,filled:filled})
			return map
		}
		
		/**
		 * Resets the collection, unload length and clear all items.
		 * 
		 * The collection will reload itself its pages when accessed later on.
		 */
		public function reset() : void {
			if ( !_isLoadingItems && !_isLoadingLength) {
				_length = 0 ;
				_isLengthLoaded = false ;
				_notLoadedItemsCount = 1 ;
				removeAll() ;
				loadLength() ;
			}
		}
		
		/**
		 * Returns a Slave collection based on this one.
		 * 
		 * Note that the slave collection will only display the items already loaded, and is not aware of the asynchronous nature of its master collection<br/>
		 * Hence, a SlaveCollection here may have holes in it, when the master is not fully loaded.<br/>
		 * However, the slave collection will fill-up by itself when its master is being progressively loaded.
		 */
		public function getSlaveCollection():SlaveCollection
		{
			return new SlaveCollection(this);
		}		
		
		private function _isItemLoaded(index:int) : Boolean {
			if ( index >= super.length )
				return false ;
			try {
				return super.getItemAt(index) != null ;
			} catch (e:RangeError) {
				
			}	
			return false ;	
		}
		
		private function _forEach(f:Function,data:Object,fromIndex:int = 0) : void {
			_isLoadingAllPages = true ;
			if ( !_isLengthLoaded ) {
				_loadLength().resultTo(
					function (note:IKlovisNotification) : void {
						_forEach(f,data,fromIndex) ;
					}
				) ;
				return ;
			}
			
			for (var iItem:int=fromIndex; iItem < _length ; iItem++) {
				if ( !_isItemLoaded(iItem) ) {
					_loadItemAt(iItem, 
						function (index:int) : void {
							_forEach(f,data,index) ;
						}
					)
					;
					return ;
				} else {
					var item :Object = super.getItemAt(iItem) ;
					var mustContinue : Boolean = f(iItem,item,data) as Boolean ;
					if ( !mustContinue ) {
						_isLoadingAllPages = false ;
						break ;						
					} 
					if ( iItem == _length -1 ) {
						_isLoadingAllPages = false ;	
					}
				}	
			}
		}
		
		private function _loadLength() : IKlovisNotification {
			if ( !_isLoadingLength ) {
				_isLoadingLength = true ;
				_notificationLengthInProgress = loadLength().resultTo(_onLengthLoaded).faultTo(_onLengthFailed) ;
			}
			return _notificationLengthInProgress ;
		}
		
		private function _onLengthLoaded(result:Object) : void {
			_length = getLengthFromResult(result) ;
			_notLoadedItemsCount = _length
			_isLoadingLength = false ;
			_isLengthLoaded = true ;
			_notificationLengthInProgress = null ;
			removeAll() ;
			var event:CollectionEvent =
			new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
           	event.kind = CollectionEventKind.RESET;
           	dispatchEvent(event);
           	dispatchEvent(new AsyncPagedCollectionEvent(AsyncPagedCollectionEvent.LENGTH_LOADED_EVENT,_length)) ;
			//_copyItems(_length) ;
		}
		
		private function _onLengthFailed(fault:Object) : void {
			_isLoadingLength = false ;
			_isLengthLoaded = false ;
			_notificationLengthInProgress = null ;
		}
		
		private function _copyItems(newLength:int) : void {
			var newSource : Array = new Array(newLength) ;
			/*var oldLength : int = source.length
			for (var i:int = 0 ; i < oldLength ; i++) {
				if ( i < newLength ) {
					newSource[i] = source[i]
				}
			}*/
			source = newSource ;
		}
		
		
		private function _loadItemAt(index:int, callback:Function = null) : void {
			if (_isDisposed)
				return ;
			if ( callback != null )
				_indexesCallBack[index] = callback ;
			if ( _isLoadingItems ) {
				if ( _indexesToLoad2.indexOf(index) < 0 )
					_indexesToLoad2.push(index) ;
				return ;
			}

			if ( _indexesToLoad.length == 0 || (_indexesToLoad.length >0 && _timeOutToken ==0) ) {
				trace("index: " + index + ", StartRecord at " + getTimer() ) ;
				_startRecordIndexes()
			} else {
				_lastIndexTime = getTimer() ;
				trace("index: " + index + ", lastItemIndex = " + _lastIndexTime)
				if ( index == _length -1 )
					trace(new Error().getStackTrace())
			}
			if ( _indexesToLoad.indexOf(index) < 0 && !_itemsLoading.hasOwnProperty(String(index))) { 
				_indexesToLoad.push(index) ;
			}
		}
		
		private function _startRecordIndexes() : void {
			_lastIndexTime = getTimer() ;
			_timeOutToken = setTimeout(_timerFunction,_timeDelay) ;
		}
		
		private function _timerFunction() : void {
			if (_isDisposed)
				return  ;
			clearTimeout(_timeOutToken) ;
			_timeOutToken = 0 ;
			var time : int = getTimer() ;
			//trace("timer: " + (time - _lastIndexTime)) ;
			if ( time - _lastIndexTime > _accumulationDelay ) {
				//trace("stopRecording at " + time) ;
				_stopRecordingIndexes() ;
			} else {
				if ( _timeOutToken == 0 )
					_timeOutToken = setTimeout(_timerFunction,_timeDelay) ;
				//trace("restartTimeOut at " + time) ;
			}
		}
		
		private function _getIndexesToLoad() : Array {
			var indexes:Array = [] ;
			if ( _isLoadingAllPages || _listControls.length == 0)
				indexes = _indexesToLoad ;
			else {	
				indexes = [] ;
				for each (var list:ListBase in _listControls) {
					var startIndex : int = list.verticalScrollPosition ;
					var length : int = list.rowCount ;
					for (var i:int = 0 ; i <= length ; i++) {
						var idx : int = startIndex + i ;
						if ( idx > _length )
							break ;
						if (indexes.indexOf(idx) < 0 && !_isItemLoaded(idx) )
							indexes.push(idx)
					}
				}
			}
			for each (var index:int in indexes )			 
				_itemsLoading[index] = true ;
			return indexes
		}
		
		private function _getPageSize(indexesToLoad:Array) : int {
			var result : int ;
			if ( _listControls.length == 0 || !autoPageSize)
				result = pageSize ;
			else {
				for each (var list:ListBase in _listControls) {
					var length : int = list.rowCount + 1;
					result = Math.max(result,length) ;
				}
				/*
				// If there is only one control attached, then its easy to optimize page size so that we minimize the number of pages to load, and load a single page
				if ( _listControls.length == 1) {
					var pageNum : int = indexesToLoad[0] / result ;
					var indexCount : int = indexesToLoad.length ;	
					// If we take an exact pageNumber, then calculate how many items are missing ?
					var missingItemsCount :int = indexesToLoad[0] - (pageNum * result) ;
					// add missing item
					for (var i:int = 0; i < missingItemsCount ; i++) {
						indexesToLoad.splice(i,0,(pageNum*result)+i) ;
					}
					// adjust page size to be loaded
					result += missingItemsCount ;
				}
				*/
				
			}
			return result ;
		}
		
		private function _stopRecordingIndexes() : void {
			if (_isDisposed)
				return ;
			var indexes : Array = _getIndexesToLoad() ;
			var pageSize : int = _getPageSize(indexes) ;	
			
			indexes.sort(Array.NUMERIC) ;
			var pages:Pages = new Pages(pageSize) ;
			// Break indexes into multiple page loads
			pages.buildPages(indexes) ;
			//trace("indexes to load: " + indexes.length + " pages: " + pages.pages.length) ;
			if ( pages.pages.length)
				_loadPages(pages);
		}
		
		private function _loadPages(pages:Pages) : void {
			var length : int = pages.pages.length
			_isLoadingItems = true ;
			var processed : int = 0 ;
			for (var iPage:int = 0 ; iPage<length; iPage++) {
				var page:Page = pages.pages[iPage] ;
				trace("loading page: " + page.pageNumber ) ;
				loadPage(page).withData(page).resultTo(
					function (notif:IKlovisNotification) : void {
						if (_isDisposed)
							return ;
						_onPageLoaded(notif) ;
						processed++ ;
						if ( processed == length) {
							_indexesToLoad = [] ;
							_isLoadingItems = false ;
							_processSecondaryIndexes() ;
						}
					}
				).faultTo(
					function (fault:Object) : void {
						if (_isDisposed)
							return  ;
						if ( processed == length) {
							_indexesToLoad = [] ;
							_isLoadingItems = false ;
							_processSecondaryIndexes() ;
						}	
					}
				) ;
			}
		}
		
		private function _onPageLoaded(notif:IKlovisNotification) : void {
			var result : Object = notif.resultData ;
			var items:Array = getItemsFromResult(result) ;
			var page:Page = notif.data as Page ;
			trace("pageResult: " + page.pageNumber) ;
			var length : int = items.length
			
			var currentLength:int = super.length ;
			var lastIndex:int = page.start + length
			
			var delta:int = lastIndex - currentLength ;
			if ( delta >= 0) {
				var source : Array = this.source ;
				while (--delta >=0)
					source.push(null) ;
			}
			
			for (var i:int = 0 ; i < length ; i++) {
				var item:Object = items[i]
				var targetIndex : int = page.start + i
				if ( targetIndex < _length) {
					super.setItemAt(item, targetIndex) ;
					_notLoadedItemsCount-- ;
					if (_notLoadedItemsCount == 0) {
						dispatchEvent(new AsyncPagedCollectionEvent(AsyncPagedCollectionEvent.COLLECTION_LOADED_EVENT)) ;
						_isLoadingAllPages = false ;
					}
				}
				delete _itemsLoading[targetIndex] ;
				trace("processed index " + targetIndex) ;
				dispatchEvent(new AsyncPagedCollectionEvent(AsyncPagedCollectionEvent.PAGE_LOADED_EVENT,0,page)) ;
			}
			
			for (i = 0 ; i < length ; i++) {
				targetIndex = page.start + i
				var callback:Function = _indexesCallBack[targetIndex] as Function ;
				if ( callback != null ) {
					delete _indexesCallBack[targetIndex] ;
					callback(targetIndex) ;
				}
			}
		}
		
		private function _processSecondaryIndexes() : void {
			trace("processing secondary indexes: " + _indexesToLoad2.length + " items") ;
			for each (var index:int in _indexesToLoad2) {
				getItemAt(index) ;
			}
			_indexesToLoad2 = [] ;
		}
	}
}
	import fr.kapit.flex.util.pagedCollectionClasses.Page;
	

	

class Pages {
	public var pages : Array = []
	public var pageSize : int ;
	public function Pages(pageSize:int = 10) {
		this.pageSize = pageSize ;
	}
	
	public function buildPages(indexes:Array) : void {
		for each (var idx:int in indexes) {
			addItem(idx) ;
			trace("building pages, index =" + idx);
		}
	}
	
	public function addItem(idx:int) : void {
		var page:Page
		if ( pages.length == 0 ) {
			page = new Page(idx,pageSize) ;
			pages.push(page) ;
			return ;
		}	else {
			page = pages[pages.length - 1] as Page;
			if (page.addIndex(idx) == false) {
				pages.push(new Page(idx,pageSize)) ;
			}
		}
	}
}

