@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to locate and browse through tag collection listings

  Scenario: Tags and synonyms of the tag show up in the tag's collection listing
  Given a set of collections for searching
  When I go to the collections page
    And I follow "The Best Tag"
  Then I should see the page title "The Best Tag - Collections"
    And I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
    And I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Surprise Presents"
    But I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: We can further filter a tag's collection listing with collection_search_tag
  Given a set of collections for searching
  When I go to the collections page
    And I follow "The Best Tag"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I fill in "collection_search_tag" with "The Better Tag"
    And I press "Sort and Filter"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "1 Collection" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
    And I should see "Some Test Collection"
    But I should not see "Some Other Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: We can filter a tag's collection listing with radio buttons
  Given a set of collections for searching
  When I go to the collections page
    And I follow "The Best Tag"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I choose "collection_search_challenge_type_giftexchange"
    And I press "Sort and Filter"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "1 Collection" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
    And I should see "Surprise Presents"
    And I should not see "Some Test Collection"
    But I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: We can find collection listings for a tag through a collection profile
  Given a set of collections for searching
  When I go to "Some Test Collection" collection's page
    And I follow "Profile"
    And I follow "The Best Tag" within ".tags"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"

  Scenario: We can find collection listings for a tag through the tag profile
  Given a set of collections for searching
  When I view the tag "The Best Tag"
    And I follow "filter collections"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  
  Scenario: We can find collection listings for a tag through the buttons at the top of the tag profile and its works/bookmarks pages
  Given a set of collections for searching
  When I view the tag "The Best Tag"
    And I follow "Collections" within ".primary.header.module"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I follow "Works" within "#main"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "Works" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I follow "Collections" within "#main"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I follow "Bookmarks" within "#main"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "Bookmarked Items" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  When I follow "Collections" within "#main"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
  
  Scenario: A tag's collection listings should update when a collection's tags are edited
  Given a set of collections for searching
  When I am logged in as the owner of "Some Other Collection"
    And I go to "Some Other Collection" collection's page
    And I follow "Profile"
    And I follow "Collection Settings"
    And I fill in "Collection Tags" with ""
    And I press "Update"
    And all indexing jobs have been run
    And I view the tag "The Best Tag"
    And I follow "Collections" within ".primary.header.module"
  Then I should see "The Best Tag" within "h2.heading"
    And I should see "2 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
    And I should see "Some Test Collection"
    And I should see "Surprise Presents"
    But I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"