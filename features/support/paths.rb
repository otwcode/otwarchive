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
    when /the media page/
      media_index_path
    when /^the search bookmarks page$/i
      step %{all indexing jobs have been run}
      search_bookmarks_path
    when /^the search tags page$/i
      step %{all indexing jobs have been run}
      search_tags_path
    when /^the search works page$/i
      step %{all indexing jobs have been run}
      search_works_path
    when /^the collections page$/i
      step %{all indexing jobs have been run}
      collections_path
    when /^the search people page$/i
      step %{all indexing jobs have been run}
      search_people_path
    when /^the bookmarks page$/i
      # This cached page only expires by time, not by any user action;
      # just clear it every time.
      Rails.cache.delete "bookmarks/index/latest/v3"
      bookmarks_path
    when /^the works page$/i
      # This cached page only expires by time, not by any user action;
      # just clear it every time.
      Rails.cache.delete "works/index/latest/v2"
      works_path
    when /^the admin login page$/i
      new_admin_session_path
    when /^the redirect page$/i
      redirect_path

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, extra: $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, extra: $2                               #  or the forum's edit page

    # Add more mappings here.

    when /^the tagsets page$/i
      tag_sets_path
    when /^the login page$/i
      new_user_session_path
    when /^account creation page$/i
      signup_path
    when /^invite requests page$/i
      invite_requests_path
    when /^the manage invite queue page$/i
      manage_invite_requests_path
    when /the blocked users page for "([^"]*)"/
      user_blocked_users_path(Regexp.last_match(1))
    when /the muted users page for "([^"]*)"/
      user_muted_users_path(Regexp.last_match(1))
    when /^(.*)'s claims page$/
      user_claims_path(Regexp.last_match(1))
    when /^(.*)'s signups page$/
      user_signups_path(Regexp.last_match(1))
    when /^(.*)'s inbox page$/
      user_inbox_path(Regexp.last_match(1))
    when /^(.*)'s co-creator requests page$/
      user_creatorships_path(Regexp.last_match(1))
    when /the gifts page$/
      gifts_path
    when /the gifts page for the recipient (.*)$/
      gifts_path(recipient: $1)
    when /^the assignments page for "(.*)"$/
      user_assignments_path(Regexp.last_match(1))
    when /^(.*)'s collection items page$/
      user_collection_items_path(Regexp.last_match(1))
    when /^(.*)'s gifts page/
      user_gifts_path(user_id: $1)
    when /the import page/
      new_work_path(import: 'true')
    when /the public skins page/
      skins_path
    when /the work-skins page/
      skins_path(skin_type: "WorkSkin")
    when /^(.*?)(?:'s)? user page$/i
      user_path(id: $1)
    when /^the (user|dashboard) page for user "(.*?)" with pseud "(.*?)"$/i
      user_pseud_path(user_id: Regexp.last_match(2), id: Regexp.last_match(3))
    when /^(.*?)(?:'s)? user url$/i
      user_url(id: $1)
    when /^([^ ]*?)(?:'s)? works page$/i
      step %{all indexing jobs have been run}
      user_works_path(user_id: $1)
    when /^the works page for user "(.*?)" with pseud "(.*?)"$/i
      step %{all indexing jobs have been run}
      user_pseud_works_path(user_id: Regexp.last_match(1), pseud_id: Regexp.last_match(2))
    when /^the "(.*)" work page/
      # TODO: Avoid this in favor of 'the work "title"', and eventually remove.
      work_path(Work.find_by(title: $1))
    when /^the work page with title (.*)/
      # TODO: Avoid this in favor of 'the work "title"', and eventually remove.
      work_path(Work.find_by(title: $1))
    when /^the work "(.*?)"$/
      work_path(Work.find_by(title: $1))
    when /^the work "(.*?)" in full mode$/
      work_path(Work.find_by(title: $1), view_full_work: true)
    when /^the ([\d]+)(?:st|nd|rd|th) chapter of the work "(.*?)"$/
      work = Work.find_by(title: $2)
      chapter = work.chapters_in_order(include_content: false)[$1.to_i - 1]
      work_chapter_path(work, chapter)
    when /^the bookmarks page for the work "(.*)"$/i
      work_bookmarks_path(Work.find_by(title: Regexp.last_match(1)))
    when /^the bookmarks page for user "(.*)" with pseud "(.*)"$/i
      step %{all indexing jobs have been run}
      user_pseud_bookmarks_path(user_id: $1, pseud_id: $2)
    when /^(.*?)(?:'s)? bookmarks page$/i
      step %{all indexing jobs have been run}
      user_bookmarks_path(user_id: $1)
    when /^(.*?)(?:'s)? pseuds page$/i
      user_pseuds_path(user_id: $1)
    when /^(.*?)(?:'s)? manage invitations page$/i
      manage_user_invitations_path(user_id: $1)
    when /^(.*?)(?:'s)? invitations page$/i
      user_invitations_path(user_id: $1)
    when /^(.*?)(?:'s)? reading page$/i
      user_readings_path(user_id: $1)
    when /^(.*?)(?:'s)? series page$/i
      user_series_index_path(user_id: $1)
    when /^the series page for user "(.*?)" with pseud "(.*?)"$/i
      step %{all indexing jobs have been run}
      user_pseud_series_index_path(user_id: Regexp.last_match(1), pseud_id: Regexp.last_match(2))
    when /^(.*?)(?:'s)? stats page$/i
      user_stats_path(user_id: $1)
    when /^(.*?)(?:'s)? preferences page$/i
      user_preferences_path(user_id: $1)
    when /^(.*?)(?:'s)? related works page$/i
      user_related_works_path(user_id: $1)
    when /^the subscriptions page for "(.*)"$/i
      user_subscriptions_path(user_id: $1)
    when /^(.*?)(?:'s)? profile page$/i
      user_profile_path(user_id: $1)
    when /^(.*)'s skins page/
      user_skins_path(user_id: $1)
    when /^(.*)'s edit multiple works page/
      show_multiple_user_works_path(user_id: Regexp.last_match(1))
    when /^"(.*)" skin page/
      skin_path(Skin.find_by(title: $1))
    when /^the new skin page/
      new_skin_path
    when /^the new wizard skin page/
      new_skin_path(wizard: true)
    when /^"(.*)" edit skin page/
      edit_skin_path(Skin.find_by(title: $1))
    when /^"(.*)" edit wizard skin page/
      edit_skin_path(Skin.find_by(title: $1), wizard: true)
    when /^the new collection page/
      new_collection_path
    when /^"(.*)" collection's page$/i                         # e.g. when I go to "Collection name" collection's page
      step %{all indexing jobs have been run} # reindex to show recent works/bookmarks
      collection_path(Collection.find_by(title: $1))
    when /^"(.*)" collection edit page$/i
      edit_collection_path(Collection.find_by(title: $1))
    when /^the "(.*)" signups page$/i                          # e.g. when I go to the "Collection name" signup page
      collection_signups_path(Collection.find_by(title: $1))
    when /^the "(.*)" requests page$/i                         # e.g. when I go to the "Collection name" signup page
      collection_requests_path(Collection.find_by(title: $1))
    when /^the "(.*)" assignments page$/i                      # e.g. when I go to the "Collection name" assignments page
      collection_assignments_path(Collection.find_by(title: $1))
    when /^the "(.*)" participants page$/i                      # e.g. when I go to the "Collection name" participants page
      collection_participants_path(Collection.find_by(title: $1))
    when /^"(.*)" collection's url$/i                          # e.g. when I go to "Collection name" collection's url
      collection_url(Collection.find_by(title: $1))
    when /^"(.*)" gift exchange edit page$/i
      edit_collection_gift_exchange_path(Collection.find_by(title: $1))
    when /^"(.*)" gift exchange matching page$/i
      collection_potential_matches_path(Collection.find_by(title: $1))
    when /^the works tagged "(.*?)" in collection "(.*?)"$/i
      step %{all indexing jobs have been run}
      collection_tag_works_path(Collection.find_by(title: $2), Tag.find_by_name($1))
    when /^the works tagged "(.*)"$/i
      step %{all indexing jobs have been run}
      tag_works_path(Tag.find_by_name($1))
    when /^the bookmarks tagged "(.*)"$/i
      step %{all indexing jobs have been run}
      tag_bookmarks_path(Tag.find_by_name($1))
    when /^the bookmarks in collection "(.*)"$/i
      step %{all indexing jobs have been run}
      collection_bookmarks_path(Collection.find_by(title: $1))
    when /^the first bookmark for the work "(.*?)"$/i
      work = Work.find_by(title: Regexp.last_match(1))
      bookmark_path(work.bookmarks.first)
    when /^the first bookmark for the series "(.*?)"$/i
      series = Series.find_by(title: Regexp.last_match(1))
      bookmark_path(series.bookmarks.first)
    when /^the new bookmark page for work "(.*?)"$/i
      new_work_bookmark_path(Work.find_by(title: Regexp.last_match(1)))
    when /^the tag comments? page for "(.*)"$/i
      tag_comments_path(Tag.find_by_name($1))
    when /^the work comments? page for "(.*?)"$/i
      work_comments_path(Work.find_by(title: $1), show_comments: true)
    when /^the work kudos page for "(.*?)"$/i
      work_kudos_path(Work.find_by(title: $1))
    when /^the FAQ reorder page$/i
      manage_archive_faqs_path
    when /^the Wrangling Guidelines reorder page$/i
      manage_wrangling_guidelines_path
    when /^the tos page$/i
      tos_path
    when /^the faq page$/i
      archive_faqs_path
    when /^the wrangling guidelines page$/i
      wrangling_guidelines_path
    when /^the support page$/i
      new_feedback_report_path
    when /^the new tag ?set page$/i
      new_tag_set_path
    when /^the "(.*)" tag ?set edit page$/i
      edit_tag_set_path(OwnedTagSet.find_by(title: $1))
    when /^the "(.*)" tag ?set page$/i
      tag_set_path(OwnedTagSet.find_by(title: $1))
    when /^the Open Doors tools page$/i
      opendoors_tools_path
    when /^the Open Doors external authors page$/i
      opendoors_external_authors_path
    when /^the claim page for "(.*)"$/i
      claim_path(invitation_token: Invitation.find_by(invitee_email: $1).token)
    when /^the languages page$/i
      languages_path
    when /^the wranglers page$/i
      tag_wranglers_path
    when /^the wrangling page for "(.*)"$/i
      tag_wrangler_path(User.find_by(login: Regexp.last_match(1)))
    when /^the unassigned fandoms page $/i
      unassigned_fandoms_path
    when /^the "(.*)" fandoms page$/i
      media_fandoms_path(Media.find_by(name: Regexp.last_match(1)))
    when /^the "(.*)" tag page$/i
      tag_path(Tag.find_by_name($1))
    when /^the '(.*)' tag edit page$/i
      edit_tag_path(Tag.find_by(name: Regexp.last_match(1)))
    when /^the "(.*)" tag edit page$/i
      edit_tag_path(Tag.find_by(name: Regexp.last_match(1)))
    when /^the new tag page$/i
      new_tag_path
    when /^the wrangling tools page$/
      tag_wranglings_path
    when /^the new external work page$/i
      new_external_work_path
    when /^the external works page$/i
      external_works_path
    when /^the external works page with only duplicates$/i
      external_works_path(show: :duplicates)
    when /^the forgot password page$/i
      new_user_password_path
    when /^the edit user password page$/i
      edit_user_password_path
    when /^the (.*) mass bin$/i
      tag_wranglings_path(show: Regexp.last_match(1).pluralize)
    when /^the tags page$/i
      tags_path
    when /^the orphan all works page$/i
      new_orphan_path
    when /^the activation page for "(.*)"$/i
      activate_path(id: User.find_by(login: Regexp.last_match(1)).confirmation_token)
    when /^the first login help page$/i
      help_first_login_path

    # Admin Pages
    when /^the admin-posts page$/i
      admin_posts_path
    when /^the "(.*)" admin post page$/i
      admin_post_path(AdminPost.find_by(title: Regexp.last_match(1)))
    when /^the unreviewed comments page for the admin post "(.*)"$/i
      unreviewed_admin_post_comments_path(AdminPost.find_by(title: Regexp.last_match(1)))
    when /^the admin-settings page$/i
      admin_settings_path
    when /^the admin-activities page$/i
      admin_activities_path
    when /^the admin-blacklist page$/i
      admin_blacklisted_emails_path
    when /^the manage users page$/
      step "all indexing jobs have been run"
      admin_users_path
    when /^the bulk email search page$/i
      bulk_search_admin_users_path
    when /^the user administration page for "(.*)"$/i
      admin_user_path(User.find_by(login: $1))
    when /^the new admin password page$/i
      new_admin_password_path
    when /^the edit admin password page$/i
      edit_admin_password_path
    when /^the support notices page$/i
      admin_support_notices_path

    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by(login: $1))

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
