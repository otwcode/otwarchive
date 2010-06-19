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
  
  # show a section if it's not empty or if the parent collection has it
  def show_collection_section(collection, section)
    if ["intro", "faq", "rules"].include?(section) # just a check that we're not using a bogus section string
      !collection.collection_profile.send(section).blank? || collection.parent && !collection.parent.collection_profile.send(section).blank?
    end
  end

  # show collection preface if at least one section of the profile (or the parent collection's profile) is not empty
  def show_collection_preface(collection)
    show_collection_section(collection, "intro") || show_collection_section(collection, "faq") || show_collection_section(collection, "rules")
  end
  
  # show navigation to relevant sections of the profile if needed
  def show_collection_profile_navigation(collection, section)
    ["intro", "faq", "rules"].each do |s|
      if show_collection_section(collection, s) && s != section
        return true # if at least one other section than the current one is not blank, we need the navigation; break out of the each...do
      end
    end
    return false # if it passed through all tests above and not found a match, then we don't need the navigation
  end
  
  def challenge_class_name(collection)
    collection.challenge.class.name.demodulize.tableize.singularize
  end
  
  def show_collections_data(work)
    collections = work.approved_collections
    collections.collect {|coll| link_to coll.title, collection_path(coll)}.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end
  

  
  def challenge_assignment_byline(assignment)
    if assignment.offer_signup 
      assignment.offer_signup.pseud.byline 
    elsif assignment.pinch_hitter 
      assignment.pinch_hitter.byline + "* (pinch hitter)" 
    else
      ""
    end
  end
  
  def challenge_assignment_email(assignment)
    if assignment.offer_signup 
      user = assignment.offer_signup.pseud.user
    elsif assignment.pinch_hitter 
      user = assignment.pinch_hitter.user
    else
      user = nil
    end
    if user
      mailto_link user, :subject => "[#{h(@collection.title)}] Message from Collection Maintainer"
    end
  end
  
  def collection_search_header(collection, search_query)
    if search_query.blank?
      search_query = " found"
    else
      search_query = html_escape search_query
      search_query = " found for '" + search_query + "'"
    end
  
    if collection.total_pages < 2
      case collection.size
      when 1; "1 Collection" + search_query
      else; collection.total_entries.to_s + " Collections" + search_query
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + "Collections" + search_query
    end
  end
  
end
