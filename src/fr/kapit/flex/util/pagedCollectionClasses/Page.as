////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////

package fr.kapit.flex.util.pagedCollectionClasses
{
	/**
	 * This class defines coordinates for Pages to load from a server, for a paginated Collection.
	 * 
	 * There are two distinc modes to access a page<br/>
	 * <li>variable page mode: by firstElementIndex and size to load</li>
	 * <li>fixed page mode: by pageNumber and pageLength</li>
	 * The class AsyncPagedCollection uses the second mode only.
	 * 
	 * @see fr.kapit.flex.util.AsyncPagedCollection
	 */
	public  class Page 
	{
		/**
		 * index of the first object to load
		 */
		public var start:int;
		/**
		 * number of items to load
		 */
		public var length:int;
		
		/**
		 * Number of the page to load, starting at zero.
		 * 
		 */
		public var pageNumber:int;
		/**
		 * Length of a page
		 */
		public var pageLength:int;
		
		
		public function get lastIdx():int
		{
			return start + length - 1;
		}
		
		/**
		 * Constructor.
		 * 
		 * @param start the first index to load, that may not be on a page boundary
	 	 * @param pageLength if specified, this means that "fixed page mode" will be used, and start position will be adjusted to the lower multiple of pageLength, and pageNumber will be calculated
	 	 * If pageLength == 0, then the pagesize will grow with every item added, otherwise it will be fixed.
		 */ 
		public function Page(start:int, pageLength:int = 0) 
		{
			initPage(start, pageLength);
		}
		
		private function initPage(start:int, pageLength:int):void
		{
			if (pageLength > 0) 
			{
				this.pageLength = pageLength;
				pageNumber = start/pageLength;
				this.start = pageNumber * pageLength;
				length = start - this.start + 1;
			}
			else 
			{
				this.start = start;	
				length = 1;
			}
		}
		
		/**
		 * Add an index in the page, must be consecutive to last added index to be accepted.
		 * @param idx the index to add
		 * @return true if the index has been accepted and added, false otherwise (page break)
		 */
		public function addIndex(idx:int):Boolean 
		{
			var max:int = 0;
			if ( pageLength > 0 ) 
			{
				max = pageLength;
			}
			if (idx - lastIdx == 1 && (max == 0 || length < max))
			{
				length++ ;
				return true ;
			}
			return false ;
		}
	}
}