module UsersHelper
  
  # Can be used to check ownership of items
  def is_author_of?(item) 
    current_user.is_a?(User) ? current_user.is_author_of?(item) : false
  end
  
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
	  conditions = logged_in? ? "posted = 1" : "posted = 1 AND restricted = 0 OR restricted IS NULL"
	  pseud.works.find(:all, :order => "works.revised_at DESC", :conditions => conditions).each do |work|
      result += (render :partial => 'works/work_blurb', :locals => {:work => work})
    end
    result
  end
  
  def sidebar_pseud_link_text(user, pseud)
    if current_page?(user)
      text = ts("Pseuds")
    elsif pseud.present? && !pseud.new_record?
      text = pseud.name
    else
      text = user.login
    end
    (text + ' &#8595;').html_safe
  end
  
  # Prints user pseuds with links to anchors for each pseud on the page and the description as the title
  def print_pseuds(user)
    user.pseuds.collect(&:name).join(", ")
  end
  
  # Determine which icon to show on user pages
  def standard_icon(user=nil, pseud=nil)
    if pseud && pseud.icon
      pseud.icon.url(:standard)
    elsif user && user.default_pseud && user.default_pseud.icon
      user.default_pseud.icon.url(:standard)
    else
      "/images/skins/iconsets/default/icon_user.png"
    end
  end
  
  # no alt text if there isn't specific alt text
  def icon_display(user=nil, pseud=nil)
    path = user ? (pseud ? user_pseud_path(pseud.user, pseud) : user_path(user)) : nil
    pseud ||= user.default_pseud if user
    icon = standard_icon(user, pseud)
    alt_text = pseud.try(:icon_alt_text) || nil

    if path
      link_to image_tag(icon, :alt => alt_text, :class => "icon"), path
    else
      image_tag(icon, :class => "icon")
    end
  end
  
  # Prints coauthors
  def print_coauthors(user)
    user.coauthors.collect(&:name).join(", ")
  end 
  
  # Prints link to bookmarks page with user-appropriate number of bookmarks
  # (The total should reflect the number of bookmarks the user can actually see.)
  def print_bookmarks_link(user, pseud=nil)
    return print_pseud_bookmarks_link(pseud) if pseud.present? && !pseud.new_record?
    total = BookmarkSearch.count_for_pseuds(user.pseuds)
	  span_if_current ts("Bookmarks (%{bookmark_number})", :bookmark_number => total.to_s), user_bookmarks_path(@user)
  end
	
  def print_pseud_bookmarks_link(pseud)
    total = BookmarkSearch.count_for_pseuds([pseud])
	  span_if_current ts("Bookmarks (%{bookmark_number})", :bookmark_number => total.to_s), user_pseud_bookmarks_path(@user, pseud)
  end
  
  # Prints link to works page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_works_link(user, pseud=nil)
    return print_pseud_works_link(pseud) if pseud.present? && !pseud.new_record?
    total = WorkSearch.user_count(user)
	  span_if_current ts("Works (%{works_number})", :works_number => total.to_s), user_works_path(@user)
  end
  
  def print_pseud_works_link(pseud)
    total = WorkSearch.pseud_count(pseud)
	  span_if_current ts("Works (%{works_number})", :works_number => total.to_s), user_pseud_works_path(@user, pseud)
  end

  # Prints link to series page with user-appropriate number of series
  def print_series_link(user, pseud=nil)
    return print_pseud_series_link(pseud) if pseud.present? && !pseud.new_record?
    if current_user.nil?
      total = Series.visible_to_all.exclude_anonymous.for_pseuds(user.pseuds).length
    else
      total = Series.visible_to_registered_user.exclude_anonymous.for_pseuds(user.pseuds).length
    end
	  span_if_current ts("Series (%{series_number})", :series_number => total.to_s), user_series_index_path(@user)
  end
  
  def print_pseud_series_link(pseud)
    if current_user.nil?
      total = Series.visible_to_all.exclude_anonymous.for_pseuds([pseud]).length
    else
      total = Series.visible_to_registered_user.exclude_anonymous.for_pseuds([pseud]).length
    end
	  span_if_current ts("Series (%{series_number})", :series_number => total.to_s), user_pseud_series_index_path(@user, pseud)
  end
  
  def print_gifts_link(user)
    if current_user.nil?
      gift_number = user.gift_works.visible_to_all.count(:id, :distinct => true)
    else
      gift_number = user.gift_works.visible_to_registered_user.count(:id, :distinct => true)
    end
    span_if_current ts("Gifts (%{gift_number})", :gift_number => gift_number.to_s), user_gifts_path(user)
  end

  def authored_items(pseud, work_counts={}, rec_counts={})
    visible_works = pseud.respond_to?(:work_count) ? pseud.work_count.to_i : (work_counts[pseud.id] || 0)
    visible_recs = pseud.respond_to?(:rec_count) ? pseud.rec_count.to_i : (rec_counts[pseud.id] || 0)
    items = (visible_works == 1) ? link_to(visible_works.to_s + " work", user_pseud_works_path(pseud.user, pseud)) : ((visible_works > 1) ? link_to(visible_works.to_s + " works", user_pseud_works_path(pseud.user, pseud)) : "")
    if (visible_works > 0) && (visible_recs > 0)
      items += ", "
    end
    if visible_recs > 0
      items += (visible_recs == 1) ? link_to(visible_recs.to_s + " rec", user_pseud_bookmarks_path(pseud.user, pseud, :recs_only => true)) : link_to(visible_recs.to_s + " recs", user_pseud_bookmarks_path(pseud.user, pseud, :recs_only => true))
    end
    return items.html_safe
  end
  
#  def print_pseud_drafts_link(pseud)
#    total = pseud.unposted_works.size
#    link_to_unless_current t('my_drafts', :default =>"Drafts") + " (#{total})", drafts_user_pseud_works_path(@user, pseud)
#  end
  
  def authors_header(collection, what = "People")
    if collection.total_pages < 2
      case collection.size
        when 0
          "0 #{what}"
        when 1
          "1 #{what.singularize}"
        else
          collection.total_entries.to_s + " #{what}"
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + what
    end
  end

  def log_item_action_name(action)
    if action == ArchiveConfig.ACTION_ACTIVATE
      t('users_helper.log_validated', :default => 'Account Validated')
    elsif action == ArchiveConfig.ACTION_ADD_ROLE
      t('users_helper.log_role_added', :default => 'Role Added: ')
    elsif action == ArchiveConfig.ACTION_REMOVE_ROLE
      t('users_helper.log_role_removed', :default => 'Role Removed: ')
    elsif action == ArchiveConfig.ACTION_SUSPEND
      t('users_helper.log_suspended', :default => 'Suspended until ')
    elsif action == ArchiveConfig.ACTION_UNSUSPEND
      t('users_helper.log_lift_suspension', :default => 'Suspension Lifted')
    elsif action == ArchiveConfig.ACTION_BAN
      t('users_helper.log_ban', :default => 'Suspended Permanently')
    elsif action == ArchiveConfig.ACTION_WARN
      t('users_helper.log_warn', :default => 'Warned')
    elsif action == ArchiveConfig.ACTION_RENAME
      t('users_helper.log_rename', :default => 'Username Changed')
		elsif action == ArchiveConfig.ACTION_PASSWORD_RESET
      t('users_helper.log_password_change', :default => 'Password Changed')
		elsif action == ArchiveConfig.ACTION_NEW_EMAIL
      t('users_helper.log_email_change', :default => 'Email Changed')
    end
  end
  
  #Give the TOS field in the new user form a different name in non-production environments
  #so that it can be filtered out of the log, for ease of debugging
  def tos_field_name
    if Rails.env.production?
      "terms_of_service"
    else
      "terms_of_service_non_production"
    end
  end
  
end
