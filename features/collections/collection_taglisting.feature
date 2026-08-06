@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to locate and browse through tag collection listings

  Scenario: Tags and synonyms of the tag show up in the tag's collection listing
  Given a set of collections for tag page searching
  When I go to the collections page
    And I follow "My Beautiful Canonical Tag"
  Then I should see the page title "My Beautiful Canonical Tag - Collections"
    And I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should not see "Example Archive" within "h2.heading"
    And I should see "Beautiful Tag Test Collection"
    And I should see "Multiple Tag Test Collection"
    And I should see "Gorgeous Tag Test Collection"
    But I should not see "Noncanonical Tag Test Collection"
  
  Scenario: Clicking on a synonymous tag on a collection also brings you to the canonical tag's collection page
  Given a set of collections for tag page searching
  When I go to the collections page
    And I follow "My Gorgeous Synonymous Tag"
  Then I should see the page title "My Beautiful Canonical Tag - Collections"
    And I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
    And I should see "Beautiful Tag Test Collection"
    And I should see "Multiple Tag Test Collection"
    And I should see "Gorgeous Tag Test Collection"
    But I should not see "Noncanonical Tag Test Collection"

  Scenario: We can further filter a tag's collection listing with collection_search_tag
  Given a set of collections for tag page searching
  When I go to the collections page
    And I follow "My Beautiful Canonical Tag"
    And I fill in "collection_search_tag" with "a noncanonical tag"
    And I press "Sort and Filter"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "1 Collection" within "h2.heading"
    And I should see "Multiple Tag Test Collection"
    But I should not see "Beautiful Tag Test Collection"
    And I should not see "Noncanonical Tag Test Collection"
    And I should not see "Gorgeous Tag Test Collection"

  Scenario: We can further filter a tag's collection listing with radio buttons
  Given a set of collections for tag page searching
  When I go to the collections page
    And I follow "My Beautiful Canonical Tag"
    And I choose "collection_search_challenge_type_giftexchange"
    And I press "Sort and Filter"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "1 Collection" within "h2.heading"
    And I should see "Gorgeous Tag Test Collection"
    But I should not see "Beautiful Tag Test Collection"
    And I should not see "Multiple Tag Test Collection"
    And I should not see "Noncanonical Tag Test Collection"
  
  Scenario: Clearing filters brings us back to the tag's collection listing
  Given a set of collections for tag page searching
  When I go to the collections page
    And I follow "My Beautiful Canonical Tag"
    And I choose "collection_search_challenge_type_giftexchange"
    And I press "Sort and Filter"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "1 Collection" within "h2.heading"
  When I follow "Clear Filters"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"

  Scenario: We can find collection listings for a tag through a collection profile
  Given a set of collections for tag page searching
  When I go to "Beautiful Tag Test Collection" collection's page
    And I follow "Profile"
    And I follow "My Beautiful Canonical Tag" within ".tags"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
  
  Scenario: We can find collection listings for a tag through the buttons at the top of the tag profile and its works/bookmarks pages
  Given a set of collections for tag page searching
  When I view the tag "My Beautiful Canonical Tag"
    And I follow "Collections" within ".primary.header.module"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
  When I follow "Works" within "#main"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "Works" within "h2.heading"
  When I follow "Collections" within "#main"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
  When I follow "Bookmarks" within "#main"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "Bookmarked Items" within "h2.heading"
  When I follow "Collections" within "#main"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "3 Collections" within "h2.heading"
  
  Scenario: A tag's collection listings should update when a collection's tags are edited
  Given a set of collections for tag page searching
  When I am logged in as the owner of "Beautiful Tag Test Collection"
    And I go to "Beautiful Tag Test Collection" collection's page
    And I follow "Profile"
    And I follow "Collection Settings"
    And I fill in "Collection Tags" with ""
    And I press "Update"
    And all indexing jobs have been run
    And I view the tag "My Beautiful Canonical Tag"
    And I follow "Collections" within ".primary.header.module"
  Then I should see "My Beautiful Canonical Tag" within "h2.heading"
    And I should see "2 Collections" within "h2.heading"
    And I should see "Multiple Tag Test Collection"
    And I should see "Gorgeous Tag Test Collection"
    But I should not see "Beautiful Tag Test Collection"
    And I should not see "Noncanonical Tag Test Collection"