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
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;


	/**
	 * A SlaveCollection is a synchronized copy of an other ArrayCollection, with auto-synchronization.
	 * 
	 * This class will be useful to duplicate collections from the central model of an application,
	 * in order to provide filtered and sorted views of this data, without altering the central "master" collection.
	 * All changes made on the master collection will be synchronized into slave collections.<br/>
	 * When a slave collection is created, all the contents from the master will be copied at this moment, from the internal items<br/>
	 * If the master collection is sorted or filtered, the slave collection will not be either, and the order of elements in the slave collection
	 * will be the internal order (the source of the master ArrayCollection) and not the visible order.<br/>
	 * The SlaveCollection holds its own source array, copied from master, and not reference to the master.source array.<br/>
	 * Thus, every SlaveCollection is independant relatively to its sort order and filter, that will be applied dynamically when master collection changes<br/>
	 * Its also possible to chain SlaveCollections.<br/>
	 * <p> 
	 * Slave collections add event listeners onto master collections, and you should call <code>detach()</code> after using a slave collection<br/>
	 * If you forget to do so, the slave will synchronize as long as a reference onto it will exist in memory<br/>
	 * If a slave collection is not referenced elsewhere, then it will auto-detach and be available for garbage collection.
	 * </p>
	 * @see ArrayCollection 
	 */ 
	public class SlaveCollection extends ArrayCollection
	{
		public var master:ArrayCollection;
		
		/**
		 * Constructor.
		 * 
		 * Creates a slave collection from a master, all elements will be copied at this moment, and the slave will be synchronized on the master.
		 * @param master the source ArrayCollection
		 * @param deepCloning if true, then internal elements will be cloned instead of being copied by reference. This is an advanced feature not implemented yet
		 */
		public function SlaveCollection(master:ArrayCollection, deepCloning:Boolean=false)
		{
			super();
			this.master = master
			copyElementsFromMaster(deepCloning);
			attachToMaster();
		}
		
		public function sortBy(...names):SlaveCollection 
		{
			var sort:Sort = new Sort();
			var sorts:Array = [];
			for each (var name:String in names) 
			{
				var sf:SortField = new SortField(name);
				sorts.push(sf);
			}
			sort.fields = sorts;
			this.sort = sort;
			refresh();
			return this;
		}
		
		public function sortWith(fields:Array):SlaveCollection 
		{
			var sort:Sort = new Sort();
			sort.fields = fields;
			this.sort = sort;
			refresh();
			return this;
		}
		
		/**
		 * Detach the slave from its master, no more synchronization will anymore occur on the slave when the master changes.
		 */
		public function detach():void 
		{
			detachFromMaster();
		}
		
		
		private function copyElementsFromMaster(deepCloning:Boolean=false):void 
		{
			disableAutoUpdate();
			var newSource:Array = new Array(master.source.length);
			for (var i:int = 0; i < master.source.length; i++) 
			{
				newSource[i] = master.source[i];
			}
			source = newSource ;
			refresh();
			enableAutoUpdate();
		}
		
		private function attachToMaster():void 
		{
			// weak listener
			master.addEventListener(CollectionEvent.COLLECTION_CHANGE, onMasterChange, false, 0, true);
		}
		
		private function detachFromMaster():void 
		{
			master.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onMasterChange);
		}
		
		private function onMasterChange(event:CollectionEvent):void 
		{
			switch (event.kind) 
			{
				case CollectionEventKind.ADD:
					addItems(event.items, event.location);
				break;
				
				case CollectionEventKind.MOVE:
					//_moveItems(event.items, event.oldLocation, event.location);
				break;
				
				case CollectionEventKind.REMOVE:
					removeItems(event.items, event.location);
				break;
				
				case CollectionEventKind.REPLACE:
					replaceItems(event.items, event.location);
				break;
				
				case CollectionEventKind.REFRESH:
					resync(); 
				break;
				default : break;
			}
		}
		
		private function addItems(items:Array, location:int):void  
		{
			_adjustLength(location,items.count) ;
			disableAutoUpdate();
			if ( (location + items.length) > length)
			
			for each (var item:Object in items) 
			{
				item = _getItem(item) ;
				if (sort != null ) {
					source.splice(location++,0,item) ;
					refresh() ;
				} else
					addItemAt(item, location++);				
			}
			enableAutoUpdate();
		}
		
		private function removeItems(items:Array, location:int):void 
		{
			_adjustLength(location,items.count) ;
			disableAutoUpdate();
			for each (var item:Object in items) 
			{
				item = _getItem(item) ;
				if (sort != null ) {
					source.splice(location,1) ;
					refresh() ;
				} else
					removeItemAt(location);				
			}			
			enableAutoUpdate();
		}
		
		private function replaceItems(items:Array, location:int):void 
		{
			_adjustLength(location,items.count) ;
			disableAutoUpdate();
			for each (var item:Object in items) 
			{
				item = _getItem(item) ;
				if (sort != null ) {
					source[location++] = item ;
					refresh() ;
				} else
				this.setItemAt(item, location++);				
			}			
			enableAutoUpdate();
		}
		
		private function _adjustLength(firstIndex:int, itemsCount:int) : void {
			if ( ( firstIndex + itemsCount ) >= length) {
				var growth : int =  (firstIndex+itemsCount) - length + 1 ;
				disableAutoUpdate()
				for (var i:int = 0 ; i < growth ; i++) {
					super.addItem(null) ;
				}
				enableAutoUpdate()
			}
		}
		
		private function _getItem(item:Object) : Object {
			if ( item is PropertyChangeEvent ) 
				return (item as PropertyChangeEvent).newValue ;
			return item ;
		}
		
		private function resync():void 
		{
			disableAutoUpdate();
			removeAll();
			copyElementsFromMaster();
			enableAutoUpdate();
		}
	}
}