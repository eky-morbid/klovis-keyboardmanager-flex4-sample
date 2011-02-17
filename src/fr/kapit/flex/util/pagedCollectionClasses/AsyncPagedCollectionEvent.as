package fr.kapit.flex.util.pagedCollectionClasses
{
	import flash.events.Event;
	
	/**
	 * Event class for AsyncPagedCollection.
	 */
	public class AsyncPagedCollectionEvent extends Event
	{
		/**
		 * Event that will be dispatched when collection has been completely loaded
		 */
		public static const COLLECTION_LOADED_EVENT:String = "collectionLoaded" ;
		
		/**
		 * Event dispatched when a page is loaded
		 */
		public static const PAGE_LOADED_EVENT:String = "pageLoaded" ;
		
		/**
		 * Event dispatched when the length is loaded 
		 */
		public static const LENGTH_LOADED_EVENT:String = "lengthLoaded" ;		
		
		/**
		 * @private
		 */
		private var _length : int;
		
		/**
		 * @private
		 */
		private var _page:Page;
		
		/**
		 * Constructor.
		 * @param type one of the three constonts above
		 * @param length optional length of the collection
		 * @param page optional page 
		 */
		public function AsyncPagedCollectionEvent(type:String, length:int = 0 , page:Page = null)
		{
			super(type) ;
			_length = length ;
			_page = page ;
		}
		
		/**
		 * Length of the collection, for length loaded event
		 */
		public function get length():int
		{
			return _length;
		}
		
		/**
		 * Page loaded, for page loaded event
		 */
		 public function get page():Page
		 {
		 	return _page;
		 }
		
		override public function clone():Event
		{
			return new AsyncPagedCollectionEvent(type, length, page);
		}
	}
}