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

    when /^(.*)'s user page$/i
      user_path(:id => $1)
    when /^(.*)'s works page$/i
      user_works_path(:user_id => $1)
    when /^the "(.*)" work page/
      work_path(Work.find_by_title($1))
    when /^the work page with title (.*)/
      work_path(Work.find_by_title($1))
    when /^(.*)'s bookmarks page$/i
      user_bookmarks_path(:user_id => $1)
    when /^(.*)'s pseuds page$/i
      user_pseuds_path(:user_id => $1)
    when /^(.*)'s reading page$/i
      user_readings_path(:user_id => $1)
    when /^(.*)'s series page$/i
      user_series_index_path(:user_id => $1)
    when /^(.*)'s preferences page$/i
      user_preferences_path(:user_id => $1)
    when /my user page/
      user_path(current_user)
    when /my preferences page/
      user_preferences_path(current_user)
    when /my bookmarks page/
      user_bookmarks_path(current_user)
    when /the import page/
      new_work_path(:import => 'true')
    when /the work-skins page/
      skins_path(:work_skins => true)
    when /^(.*)'s skin page/
      skins_path(:user_id => $1)
    when /^"(.*)" skin page/
      skin_path(Skin.find_by_title($1))
    when /^"(.*)" edit skin page/
      edit_skin_path(Skin.find_by_title($1))
    when /^(.*) collection's page$/i
      collection_path(Collection.find_by_title($1))
    when /^"(.*)" collection's static page$/i
      static_collection_path(Collection.find_by_title($1))

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
