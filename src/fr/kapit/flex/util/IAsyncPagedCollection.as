////////////////////////////////////////////////////////////////////////////////
//
//  Kap IT  -  Copyright 2010 Kap IT  -  All Rights Reserved.
//
//  This component is distributed under the GNU LGPL v2.1 
//  (available at : http://www.hnu.org/licences/old-licenses/lgpl-2.1.html)
//
////////////////////////////////////////////////////////////////////////////////
	/**
	 * Interface for implementing an actual asynchronous "paginated" collection, that is able to load itself from a server.
	 * 
	 * @see fr.kapit.klovis.common.notification.IKlovisNotification
	 */
package fr.kapit.flex.util
{
	import fr.kapit.flex.notification.IKlovisNotification;
	import fr.kapit.flex.util.pagedCollectionClasses.Page;
	
	public interface IAsyncPagedCollection
	{
		/**
		 * Call server method for loading collection length.
		 * @return a notification object corresponding to the server operation to call
		 */
		function loadLength() : IKlovisNotification; 
		
		/**
		 * Returns the length of the collection from server result data.
		 * @param result the remote operation result, containing collection length
		 * @return collection length
		 */
		function getLengthFromResult(result:Object) : int ;
		
		/**
		 * Call server method for loading a page.
		 * @param page the Page object containing coordinates of the page to load.
		 * @return a notification object corresponding to the server operation to call
		 * With AsyncPagedCollection, the server will have to be able to process the fixed page mode, where pageIndex and pageLength are transmitted in the query<br/>
		 */
		function loadPage(page:Page) : IKlovisNotification ;
		
		/**
		 * Returns the items of the collection from server result data.
		 * @param result the remote operation result, containing collection items
		 * @return collection items array
		 */
		function getItemsFromResult(result:Object) : Array ;
	}
}