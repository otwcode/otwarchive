module CollectionsHelper
  
  # Generates a draggable, pop-up div which contains the add-to-collection form 
  def collection_link(item)
    if item.class == Chapter
      item = item.work
    end
    if logged_in?
      if item.class == Work
        link_to ts("Add To Collection"), new_work_collection_item_path(item), :remote => true
      elsif item.class == Bookmark
        link_to ts("Add To Collection"), new_bookmark_collection_item_path(item)
      end
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
    collections.collect {|coll| link_to coll.title.html_safe, collection_path(coll)}.join(ArchiveConfig.DELIMITER_FOR_OUTPUT).html_safe
  end


  # def collection_item_approval_radio_buttons(form, collection_item)
  #   fieldname = @user ? :user_approval_status : :collection_approval_status
  #   status = collection_item.send(fieldname)
  #   content_tag(:li, 
  #     (form.label fieldname do 
  #       ts("Approve") +
  #       form.radio_button fieldname, CollectionItem::APPROVED, :checked => (status == CollectionItem::APPROVED)
  #     end), 
  #     :class => "action status") + 
  #   content_tag(:li, 
  #     (form.label fieldname do
  #       ts("Reject") +
  #       form.radio_button fieldname, CollectionItem::REJECTED, :checked => (status == CollectionItem::REJECTED)
  #     end),
  #     :class => "action status")
  # end

  def challenge_assignment_byline(assignment)
    if assignment.offer_signup && assignment.offer_signup.pseud
      assignment.offer_signup.pseud.byline 
    elsif assignment.pinch_hitter 
      assignment.pinch_hitter.byline + "* (pinch hitter)" 
    else
      ""
    end
  end
  
  def challenge_assignment_email(assignment)
    if assignment.offer_signup && assignment.offer_signup.pseud
      user = assignment.offer_signup.pseud.user
    elsif assignment.pinch_hitter 
      user = assignment.pinch_hitter.user
    else
      user = nil
    end
    if user
      mailto_link user, :subject => "[#{(@collection.title)}] Message from Collection Maintainer"
    end
  end

end
