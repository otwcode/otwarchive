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
    
    # Add more mappings here.

    when /the list of works/
      works_path     
    when /the new work page/
      new_work_path
    when /the search works page/
      search_works_path
      
    when /the login page/
      login_path
    when /the logout page/
      logout_path
    when /^(.*)'s user page$/i
      user_path(:id => $1)
    when /my user page/
      user_path(current_user)
    when /the new user page/
      new_user_path
     
    when /the tag search page/
      search_tags_path

    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
