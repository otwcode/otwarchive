module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /^the search bookmarks page$/i
      Bookmark.tire.index.refresh
      search_bookmarks_path
    when /^the search tags page$/i
      Tag.tire.index.refresh
      search_tags_path
    when /^the search works page$/i
      Work.tire.index.refresh
      search_works_path      
    when /^the search people page$/i
      Pseud.tire.index.refresh
      search_people_path

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Add more mappings here.

    when /^the tagsets page$/i
      tag_sets_path
    when /^the login page$/i
      new_user_session_path
    when /^(.*)'s user page$/i
      user_path(:id => $1)
    when /^(.*)'s user url$/i
      user_url(:id => $1).sub("http://www.example.com", ArchiveConfig.APP_URL)
    when /^(.*)'s works page$/i
      Work.tire.index.refresh
      user_works_path(:user_id => $1)
    when /^the "(.*)" work page/
      work_path(Work.find_by_title($1))
    when /^the work page with title (.*)/
      work_path(Work.find_by_title($1))
    when /^(.*)'s bookmarks page$/i
      Bookmark.tire.index.refresh
      user_bookmarks_path(:user_id => $1)
    when /^(.*)'s pseuds page$/i
      user_pseuds_path(:user_id => $1)
    when /^(.*)'s reading page$/i
      user_readings_path(:user_id => $1)
    when /^(.*)'s series page$/i
      user_series_index_path(:user_id => $1)
    when /^(.*)'s preferences page$/i
      user_preferences_path(:user_id => $1)
    when /^the subscriptions page for "(.*)"$/i
      user_subscriptions_path(:user_id => $1)
    when /^(.*)'s profile page$/i
      user_profile_path(:user_id => $1)
    when /my pseuds page/
      user_pseuds_path(User.current_user)
    when /my user page/
      user_path(User.current_user)
    when /my preferences page/
      user_preferences_path(User.current_user)
    when /my bookmarks page/
      Bookmark.tire.index.refresh
      user_bookmarks_path(User.current_user)
    when /my works page/
      Work.tire.index.refresh
      user_works_path(User.current_user)
    when /my subscriptions page/
      user_subscriptions_path(User.current_user)      
    when /my profile page/
      user_profile_path(User.current_user)
    when /my claims page/
      user_claims_path(User.current_user)
    when /my signups page/
      user_signups_path(User.current_user)
    when /the import page/
      new_work_path(:import => 'true')
    when /the work-skins page/
      skins_path(:skin_type => "WorkSkin")
    when /^(.*)'s skin page/
      skins_path(:user_id => $1)
    when /^"(.*)" skin page/
      skin_path(Skin.find_by_title($1))
    when /^"(.*)" edit skin page/
      edit_skin_path(Skin.find_by_title($1))
    when /^"(.*)" collection's page$/i                      # e.g. when I go to "Collection name" collection's page
      collection_path(Collection.find_by_title($1))
    when /^the "(.*)" signups page$/i                      # e.g. when I go to "Collection name" signup page
      collection_signups_path(Collection.find_by_title($1))
    when /^the "(.*)" requests page$/i                      # e.g. when I go to "Collection name" signup page
      collection_requests_path(Collection.find_by_title($1))
    when /^"(.*)" collection's url$/i                      # e.g. when I go to "Collection name" collection's url
      collection_url(Collection.find_by_title($1)).sub("http://www.example.com", ArchiveConfig.APP_URL)
    when /^"(.*)" gift exchange edit page$/i
      edit_collection_gift_exchange_path(Collection.find_by_title($1))
    when /^"(.*)" collection's static page$/i
      static_collection_path(Collection.find_by_title($1))
    when /^the works tagged "(.*)"$/i
      Work.tire.index.refresh
      tag_works_path(Tag.find_by_name($1))
    when /^the url for works tagged "(.*)"$/i
      Work.tire.index.refresh
      tag_works_url(Tag.find_by_name($1)).sub("http://www.example.com", ArchiveConfig.APP_URL)
    when /^the works tagged "(.*)" in collection "(.*)"$/i
      Work.tire.index.refresh
      collection_tag_works_path(Collection.find_by_title($2), Tag.find_by_name($1))
    when /^the url for works tagged "(.*)" in collection "(.*)"$/i
      Work.tire.index.refresh
      collection_tag_works_url(Collection.find_by_title($2), Tag.find_by_name($1)).sub("http://www.example.com", ArchiveConfig.APP_URL)
    when /^the admin-posts page$/i
      admin_posts_path
    when /^the admin-settings page$/i
      admin_settings_path      
    when /^the admin-notices page$/i
      notify_admin_users_path
    when /^the FAQ reorder page$/i
      manage_archive_faqs_path
    when /^the support page$/i
      new_feedback_report_path
    when /^the new tag ?set page$/i
      new_tag_set_path
    when /^the "(.*)" tag ?set edit page$/i
      edit_tag_set_path(OwnedTagSet.find_by_title($1))    
    when /^the "(.*)" tag ?set page$/i
      tag_set_path(OwnedTagSet.find_by_title($1))
      
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

