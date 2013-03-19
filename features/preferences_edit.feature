@users
Feature: Edit preferences
  In order to have an archive full of users
  As a humble user
  I want to fill out my preferences

  Scenario: View and edit preferences - viewing history, personal details, view entire work

  Given the following activated user exists
    | login         | password   |
    | editname      | password   |
  When I go to editname's user page
    And I follow "Profile"
  Then I should not see "My email address"
    And I should not see "My birthday"
  When I am logged in as "editname" with password "password"
  Then I should see "Hi, editname!"
    And I should see "Log Out"
  When I post the work "This has two chapters"
  And I follow "Add Chapter"
    And I fill in "content" with "Secondy chapter"
    And I press "Preview"
    And I press "Post"
  Then I should see "Secondy chapter"
    And I follow "Previous Chapter"
  Then I should not see "Secondy chapter"
  When I follow "editname"
  Then I should see "Dashboard" within "#dashboard .navigation li"
    And I should see "History" within "#dashboard .navigation li"
    And I should see "Preferences" within "#dashboard .navigation li"
    And I should see "Profile" within "#dashboard .navigation li"
  When I follow "Preferences" within "#dashboard .navigation li"
  Then I should see "Set My Preferences"
    And I should see "Orphan My Works"
  When I follow "Edit My Profile"
  Then I should see "Password"
  # TODO: figure out why pseud switcher doesn't show up in cukes
  # When I follow "editname" within "#pseud_switcher"
  When I follow "Dashboard"
    And I follow "Profile"
  Then I should see "Set My Preferences"
  When I follow "Set My Preferences"
  Then I should see "Edit My Profile"
  When I uncheck "Turn on Viewing History"
    And I check "Show the whole work by default."
    And I check "Show my email address to other people."
    And I check "Show my date of birth to other people."
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  # When I follow "editname"
  When I follow "Dashboard" within "#dashboard .navigation li"
  Then I should not see "History" within "#dashboard .navigation li"
  When I go to the works page
    And I follow "This has two chapters"
  Then I should see "Secondy chapter"
  When I log out
    And I go to editname's user page
    And I follow "Profile"
  Then I should see "My email address"
    And I should see "My birthday"
  When I go to the works page
    And I follow "This has two chapters"
  Then I should not see "Secondy chapter"

  Scenario: View and edit preferences - show/hide warnings and tags

  # set preference
  Given the following activated users exist
    | login          | password   |
    | mywarning1     | password   |
    | mywarning2     | password   |
    And a fandom exists with name: "Stargate SG-1", canonical: true
  When I am logged in as "mywarning1" with password "password"
  When I post the work "This work has warnings and tags" with fandom "Stargate SG-1, Stargate SG-2"
    And I follow "Edit"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "My new series"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
  When I log out
  When I am logged in as "mywarning2" with password "password"
    And I post the work "This also has warnings and tags" with fandom "Stargate SG-1, Stargate SG-2" with freeform "Scarier"
  When I view the work "This work has warnings and tags"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created"
  When I follow "This work has warnings and tags"
    And I follow "My new series"
    And I follow "Bookmark Series"
    And I press "Create"
  Then I should see "Bookmark was successfully created"

  # see everything on works index and show page
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should see "Scarier"
    And I should not see "Show additional tags"

  # see everything on fandoms page, for both canonical and unwrangled fandoms, and bookmarks page and series page
  When I follow "All Fandoms"
  Then I should see "Stargate SG-1"
    And I should see "Stargate SG-2"
  # we are now looking at a canonical fandom tag
  When I follow "Stargate SG-1"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should see "Scarier"
    And I should not see "Show additional tags"
    And I should see "Bookmarks" within "#main .navigation li"
    And I should see "Works" within "#main .navigation li"
  When I follow "All Fandoms"
  # we are now looking at a non-canonical fandom tag
    And I follow "Stargate SG-2"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should see "Scarier"
    And I should not see "Show additional tags"
    And I should not see "Bookmarks" within "#main .navigation li"
    And I should not see "Works" within "#main .navigation li"
  When I follow "My new series"
  Then I should see "This work has warnings and tags"
    And I should not see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Scarier"
    And I should not see "Show additional tags"
  # change preference to hide warnings
 When I go to mywarning2's user page
    And I follow "Preferences"
    And I check "Hide warnings"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"

  # hidden warnings on show page, except for your own works
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should see "Scarier"
    And I should not see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should not see "No Archive Warnings Apply" within ".warning"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should see "Scarier"
    And I should not see "Show additional tags"

  # hidden warnings on fandoms page except for your own works, for both canonical and unwrangled fandoms
  When I follow "All Fandoms"
  Then I should see "Stargate SG-1"
  # we're looking at a canonical tag preferences set to hide warnings
  When I follow "Stargate SG-1"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".own .tags"
    # we can see warnings on works that we created
    And I should not see "No Archive Warnings Apply" within ".work .tags"
    # we cannot see warnings on works which we do not own
    And I should see "No Archive Warnings Apply" within "#work .work"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should see "Scarier"
    And I should not see "Show additional tags"
  When I follow "All Fandoms"
  # we're looking at a non-canonical tag page, preferences set to hide warnings
    And I follow "Stargate SG-2"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should not see "No Archive Warnings Apply" within "#work .work"
    And I should see "No Archive Warnings Apply" within "#work .own"
     And I should see "Show warnings"
  Then I should see "Scary tag"
    And I should see "Scarier"
    And I should not see "Show additional tags"
    And I should not see "Bookmarks" within "#main .navigation li"
    And I should not see "Works" within "#main .navigation li"
  When I follow "My new series"
  Then I should see "This work has warnings and tags"
    And I should not see "This also has warnings and tags"
    And I should not see "No Archive Warnings Apply" within ".tags"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Scarier"
    And I should not see "Show additional tags"

  # change preference to hide freeforms
  When I go to mywarning2's user page
    And I follow "Preferences"
    And I check "Hide additional tags"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"

  # hidden both on works index and show page, except for your own works
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should not see "No Archive Warnings Apply" within ".warning"
    And I should see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should see "Scarier"
    And I should not see "Show additional tags"

  # hidden both on fandoms page and bookmarks page, except for your own works, for both canonical and unwrangled fandoms
  When I follow "All Fandoms"
  Then I should see "Stargate SG-1"
  When I follow "Stargate SG-1"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".own .tags"
    # TODO: Figure out how to make this work
    # And I should not see "No Archive Warnings Apply" within ".tags" when it's not ".own"
    And I should see "Show warnings"
    # TODO: Figure out how to make this work
    And I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
  When I follow "All Fandoms"
  # we're looking at a non-canonical page, hiding freeforms and warnings
    And I follow "Stargate SG-2"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should not see "No Archive Warnings Apply" within ".tags"
     And I should see "Show warnings"
  Then I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
    And I should not see "Bookmarks" within "#main .navigation li"
    And I should not see "Works" within "#main .navigation li"
  Then I should see "This work has warnings and tags"
  When I follow "My new series"
  Then I should see "This work has warnings and tags"
    And I should not see "This also has warnings and tags"
    And I should not see "No Archive Warnings Apply" within ".tags"
    And I should see "Show warnings"
    And I should not see "Scary tag"
    And I should not see "Scarier"
    And I should see "Show additional tags"

  # change preference to show warnings, keep freeforms hidden
  When I go to mywarning2's user page
    And I follow "Preferences"
    And I uncheck "Hide warnings"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"

  # hidden only freeforms on works index and show page, except for your own works
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "No Archive Warnings Apply" within ".warning"
    And I should not see "Show warnings"
    And I should see "Scarier"
    And I should not see "Show additional tags"

  # hidden only freeforms on fandoms page and bookmarks page, except for your own works, for both canonical and unwrangled fandoms
  When I follow "All Fandoms"
  Then I should see "Stargate SG-1"
  When I follow "Stargate SG-1"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
  When I follow "fandoms"
  # we're looking at a non-canonical tag page
    And I follow "Stargate SG-2"
  Then I should see "This work has warnings and tags"
    And I should see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
  Then I should not see "Scary tag"
    And I should see "Scarier"
    And I should see "Show additional tags"
    And I should not see "Bookmarks" within "#main .navigation li"
    And I should not see "Works" within "#main .navigation li"
  When I follow "My new series"
  Then I should see "This work has warnings and tags"
    And I should not see "This also has warnings and tags"
    And I should see "No Archive Warnings Apply" within ".tags"
    And I should not see "Show warnings"
    And I should not see "Scary tag"
    And I should not see "Scarier"
    And I should see "Show additional tags"
