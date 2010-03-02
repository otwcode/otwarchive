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
  
  # Prints user pseuds with links to anchors for each pseud on the page and the description as the title
  def print_pseuds(user)
    user.pseuds.collect(&:name).join(", ")
  end
  
  # Determine which icon to show on user pages
  def standard_icon(user, pseud)
    if pseud
      pseud.icon.url
    elsif user
      user.default_pseud.icon.url
    end
  end
  
  # Prints coauthors
  def print_coauthors(user)
    user.coauthors.collect(&:name).join(", ")
  end 
  
  # Prints link to bookmarks page with user-appropriate number of bookmarks
  # (The total should reflect the number of bookmarks the user can actually see.)
  def print_bookmarks_link(user)
    total = logged_in_as_admin? ? @user.bookmarks.count : @user.bookmarks.visible.size
    if @user == current_user
	  span_if_current t('my_bookmarks', :default => "My Bookmarks ({{bookmark_number}})", :bookmark_number => total.to_s), user_bookmarks_path(@user)
	else
	  span_if_current t('bookmarks', :default => "Bookmarks ({{bookmark_number}})", :bookmark_number => total.to_s), user_bookmarks_path(@user)
	end
  end
	
  def print_pseud_bookmarks_link(pseud)
    total = logged_in_as_admin? ? pseud.bookmarks.count : pseud.bookmarks.visible.size
    if @user == current_user
	  span_if_current t('my_pseud_bookmarks', :default => "My Bookmarks ({{bookmark_number}})", :bookmark_number => total.to_s), user_pseud_bookmarks_path(@user, pseud)
	else
	  span_if_current t('pseud_bookmarks', :default => "Bookmarks ({{bookmark_number}})", :bookmark_number => total.to_s), user_pseud_bookmarks_path(@user, pseud)
	end
  end
  
  # Prints link to works page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_works_link(user)
    total = user.visible_work_count
    if @user == current_user
	  span_if_current t('my_works', :default => "My Works ({{works_number}})", :works_number => total.to_s), user_works_path(@user)
	else
	  span_if_current t('works', :default => "Works ({{works_number}})", :works_number => total.to_s), user_works_path(@user)
	end
  end
  
  def print_pseud_works_link(pseud)
    total = pseud.visible_works_count
    if @user == current_user
	  span_if_current t('my_works', :default => "My Works ({{works_number}})", :works_number => total.to_s), user_pseud_works_path(@user, pseud)
	else
	  span_if_current t('works', :default => "Works ({{works_number}})", :works_number => total.to_s), user_pseud_works_path(@user, pseud)
	end
  end

  # Prints link to series page with user-appropriate number of series
  def print_series_link(user)
    if current_user == :false
      total = Series.visible_to_public.exclude_anonymous.for_pseuds(user.pseuds).length
    else
      total = Series.visible_logged_in.exclude_anonymous.for_pseuds(user.pseuds).length
    end
    if @user == current_user
  	  span_if_current t('my_series', :default => "My Series ({{series_number}})", :series_number => total.to_s), user_series_index_path(@user)
  	else
  	  span_if_current t('series', :default => "Series ({{series_number}})", :series_number => total.to_s), user_series_index_path(@user)
  	end
  end
  
  def print_pseud_series_link(pseud)
    if current_user == :false
      total = Series.visible_to_public.exclude_anonymous.for_pseuds([pseud]).length
    else
      total = Series.visible_logged_in.exclude_anonymous.for_pseuds([pseud]).length
    end
  	if @user == current_user
  	  span_if_current t('my_series', :default => "My Series ({{series_number}})", :series_number => total.to_s), user_pseud_series_index_path(@user, pseud)
  	else
  	  span_if_current t('series', :default => "Series ({{series_number}})", :series_number => total.to_s), user_pseud_series_index_path(@user, pseud)
  	end
  end

  def print_drafts_link(user)
    total = @user.unposted_works.size
    span_if_current t('my_drafts', :default => "My Drafts") + " (#{total})", drafts_user_works_path(@user)
  end
  
  def authored_items(pseud)
    visible_works = pseud.visible_works_count
    visible_bookmarks_count = logged_in_as_admin? ? pseud.bookmarks.count : pseud.bookmarks.visible.size
    items = (visible_works == 1) ? link_to(visible_works.to_s + " work", user_pseud_works_path(pseud.user, pseud)) : ((visible_works > 1) ? link_to(visible_works.to_s + " works", user_pseud_works_path(pseud.user, pseud)) : "")
    if (visible_works > 0) && (visible_bookmarks_count > 0)
      items += " | "
    end
    if visible_bookmarks_count > 0
      items += (visible_bookmarks_count == 1) ? link_to(visible_bookmarks_count.to_s + " bookmark", user_pseud_bookmarks_path(pseud.user, pseud)) : link_to(visible_bookmarks_count.to_s + " bookmarks", user_pseud_bookmarks_path(pseud.user, pseud))
    end
    return items
  end
  
#  def print_pseud_drafts_link(pseud)
#    total = pseud.unposted_works.size
#    link_to_unless_current t('my_drafts', :default =>"My Drafts") + " (#{total})", drafts_user_pseud_works_path(@user, pseud)
#  end
  
  def authors_header(collection)
    if collection.total_pages < 2
      case collection.size
      when 0; "0 People"
      when 1; "1 Person"
      else; collection.total_entries.to_s + " People"
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + "People"
    end
  end
  
  def log_item_action_name(action)
    if action == ArchiveConfig.ACTION_ACTIVATE
      t('log_validated', :default => 'Account Validated')
    elsif action == ArchiveConfig.ACTION_ADD_ROLE
      t('log_role_added', :default => 'Role Added: ')
    elsif action == ArchiveConfig.ACTION_REMOVE_ROLE
      t('log_role_removed', :default => 'Role Removed: ')
    elsif action == ArchiveConfig.ACTION_SUSPEND
      t('log_suspended', :default => 'Suspended until ')
    elsif action == ArchiveConfig.ACTION_UNSUSPEND
      t('log_lift_suspension', :default => 'Suspension Lifted')
    elsif action == ArchiveConfig.ACTION_BAN
      t('log_ban', :default => 'Suspended Permanently')
    elsif action == ArchiveConfig.ACTION_WARN
      t('log_warn', :default => 'Warned')
    elsif action == ArchiveConfig.ACTION_RENAME
      t('log_rename', :default => 'Username Changed')
    end
  end
  
  #Give the TOS field in the new user form a different name in non-production environments
  #so that it can be filtered out of the log, for ease of debugging
  def tos_field_name
    if ENV["RAILS_ENV"]=="production"
      "terms_of_service"
    else
      "terms_of_service_non_production"
    end
  end
  
end
