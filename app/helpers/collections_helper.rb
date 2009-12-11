module CollectionsHelper
  
  # Generates a draggable, pop-up div which contains the add-to-collection form 
  def collection_link(item)
    if item.class == Chapter
      item = item.work
    end
    if logged_in? && item.class == Work
      fallback_url = new_work_collection_item_path(item)
      text = t('collections.add_to_collection', :default => "Add To Collection")
      link_to_remote text, {:url => fallback_url, :method => :get, :href => fallback_url}
    end
  end
    
end
