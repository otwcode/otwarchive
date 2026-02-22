@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to locate and browse an existing collection

  Scenario: Collections index should have different links for logged in and logged out users

  Given I am logged in as "onlooker"
  When I go to the collections page
  Then I should see "Open Challenges"
    And I should see "New Collection"
  When I log out
    And I go to the collections page
  Then I should see "Open Challenges"
    And I should not see "New Collection"

  Scenario: Filter collections index to only show prompt memes

  Given a set of collections for searching
  When I go to the collections page
    And I choose "Prompt Meme Challenge"
    And I press "Sort and Filter"
  Then I should see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"

  Scenario: Filter collections index to only show gift exchanges

  Given a set of collections for searching
  When I go to the collections page
    And I choose "Gift Exchange Challenge"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should see "Another Gift Swap"
    And I should not see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"

  Scenario: Filter collections index to only show non-challenge collections

  Given a set of collections for searching
  When I go to the collections page
    And I choose "No Challenge"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: Filter collections index to only show closed collections

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_closed_true"
    And I press "Sort and Filter"
  Then I should see "Another Plain Collection"
    And I should see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"

  Scenario: Filter collections index to only show open collections

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_closed_false"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Surprise Presents"
    And I should see "Another Gift Swap"
    And I should not see "Another Plain Collection"
    And I should not see "On Demand"

  Scenario: Filter collections index to only show moderated collections

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_moderated_true"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: Filter collections index to only show unmoderated collections

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_moderated_false"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    And I should see "Another Gift Swap"
    And I should see "On Demand"
    And I should not see "Surprise Presents"

  Scenario: Filter collections index to show open, moderated gift exchanges

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_closed_false"
    And I choose "collection_search_moderated_true"
    And I choose "Gift Exchange Challenge"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: Filter collections index by collection title

  Given a set of collections for searching
  When I go to the collections page
    And I fill in "collection_search_title" with "Another"
    And I press "Sort and Filter"
  Then I should see "Another Plain Collection"
    And I should see "Another Gift Swap"
    But I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Surprise Presents"
    And I should not see "On Demand"

  Scenario: Can't filter collections index by collection name

    Given a set of collections for searching
    When I go to the collections page
      And I fill in "collection_search_title" with "demandtest"
      And I press "Sort and Filter"
    Then I should not see "Another Plain Collection"
      And I should not see "Another Gift Swap"
      And I should not see "Some Test Collection"
      And I should not see "Some Other Collection"
      And I should not see "Surprise Presents"
      And I should not see "On Demand"

  @javascript
  Scenario: Filter collections index by collection name using autocomplete

    Given a set of collections for searching
    When I go to the collections page
      And I enter "demandte" in the "Filter by title" autocomplete field
    Then I should see "demandtest: On Demand" in the autocomplete
    When I choose "demandtest: On Demand" from the "Filter by title" autocomplete
      And I press "Sort and Filter"
    Then I should see "On Demand"
      But I should not see "Another Gift Swap"
      And I should not see "Another Plain Collection"
      And I should not see "Some Test Collection"
      And I should not see "Some Other Collection"
      And I should not see "Surprise Presents"

  @javascript
  Scenario: Filter collections index by collection title using autocomplete

    Given a set of collections for searching
    When I go to the collections page
      And I enter "Gift" in the "Filter by title" autocomplete field
    Then I should see "swaptest: Another Gift Swap" in the autocomplete
    When I choose "swaptest: Another Gift Swap" from the "Filter by title" autocomplete
    And I press "Sort and Filter"
    Then I should see "Another Gift Swap"
      But I should not see "On Demand"
      And I should not see "Another Plain Collection"
      And I should not see "Some Test Collection"
      And I should not see "Some Other Collection"
      And I should not see "Surprise Presents"

  Scenario: Filter collections by non-canonical and non-existent collection tags

  Given a set of collections for searching
  When I go to the collections page
    And I fill in "collection_search_tag" with "The Best Tag"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    But I should not see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"
  When I fill in "collection_search_tag" with "The Best Tag,The Better Tag"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    But I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"
  When I fill in "collection_search_tag" with "The Tag"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    But I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: Filter collections by multifandom

  Given a set of collections for searching
  When I go to the collections page
    And I choose "collection_search_multifandom_true"
    And I press "Sort and Filter"
  Then I should see "Another Gift Swap"
    But I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "On Demand"
    And I should not see "Surprise Presents"
  When I choose "collection_search_multifandom_false"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    And I should see "On Demand"
    And I should see "Surprise Presents"
    But I should not see "Another Gift Swap"

  Scenario: Sort collections by Works and Bookmarks

  Given I have a collection "Privates"
    And I have a collection "Publics"
  When I am logged in as the owner of "Privates"
    And I post the work "Private 1" in the collection "Privates"
    And I lock the work "Private 1"
    And I post the work "Private 2" in the collection "Privates"
    And I lock the work "Private 2"
    And I bookmark the work "Private 1" to the collection "Publics"
    And I bookmark the work "Private 2" to the collection "Publics"
    And I post the work "Public 1" in the collection "Publics"
    And I bookmark the work "Public 1" to the collection "Privates"
    And all indexing jobs have been run
    And I go to the collections page
    And I select "Works" from "collection_search_sort_column"
    And I press "Sort and Filter"
  Then I should see the text with tags '<a href="/collections/Privates/works">2</a>'
    And I should see the text with tags '<a href="/collections/Publics/works">1</a>'
  When I log out
  Then I should see the text with tags '<a href="/collections/Privates/works">0</a>'
    And I should see the text with tags '<a href="/collections/Publics/works">1</a>'
  When I am logged in as a super admin
    And I go to the collections page
    And I select "Works" from "collection_search_sort_column"
    And I press "Sort and Filter"
  Then I should see the text with tags '<a href="/collections/Privates/works">2</a>'
    And I should see the text with tags '<a href="/collections/Publics/works">1</a>'
  When I go to the collections page
    And I select "Bookmarked Items" from "collection_search_sort_column"
    And I press "Sort and Filter"
  Then I should see the text with tags '<a href="/collections/Privates/bookmarks">1</a>'
    And I should see the text with tags '<a href="/collections/Publics/bookmarks">2</a>'
  When I log out
    And I go to the collections page
    And I select "Bookmarked Items" from "collection_search_sort_column"
    And I press "Sort and Filter"
  Then I should see the text with tags '<a href="/collections/Privates/bookmarks">1</a>'
    And I should not see the text with tags '<a href="/collections/Publics/bookmarks">2</a>'
  When I am logged in as a super admin
    And I go to the collections page
    And I select "Bookmarked Items" from "collection_search_sort_column"
    And I press "Sort and Filter"
  Then I should see the text with tags '<a href="/collections/Privates/bookmarks">1</a>'
    And I should see the text with tags '<a href="/collections/Publics/bookmarks">2</a>'

  Scenario: Look at a collection, see the rules and intro and FAQ

  Given a set of collections for searching
    And I am logged in as "testuser" with password "testuser"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should see "Some Test Collection"
  When I follow "Some Test Collection"
  Then I should see "Some Test Collection"
    And I should see "There are no works or bookmarks in this collection yet."
  When I follow "Profile"
  Then I should see "Welcome to the test collection" within "#intro"
    And I should see "What is this test thing?" within "#faq"
    And I should see "It's a test collection" within "#faq"
    And I should see "Be nice to testers" within "#rules"
    And I should see "About Some Test Collection (sometest)"

  Scenario: Work blurb includes an HTML comment containing the unix epoch of the updated time
  
    Given time is frozen at 2025-04-12 17:00 UTC
      And I have the collection "Collection1"
      And a fandom exists with name: "Steven's Universe", canonical: true
      And I am logged in as a random user
      And I post the work "Stronger than you" with fandom "Steven's Universe" in the collection "Collection1"
    When I go to the collections page
      And I follow "Collection1"
    Then I should see an HTML comment containing the number 1744477200 within "li.work.blurb"

  Scenario: Collection item counts show the correct amount for guests, registered users and admins

  Given I have a collection "Item Counts"
  When I am logged in as the owner of "Item Counts"
    And I post the work "Public 1" in the collection "Item Counts"
    And I post the work "Private 1" in the collection "Item Counts"
    And I lock the work "Private 1"
    And I post the work "Private 2" in the collection "Item Counts"
    And I lock the work "Private 2"
    And I bookmark the work "Public 1" to the collection "Item Counts"
    And I bookmark the work "Private 1" to the collection "Item Counts"
    And I add the subcollection "Sub Count" to the parent collection named "Item_Counts"
    And I go to the collections page
  Then I should see the text with tags '<a href="/collections/Item_Counts/works">3</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">2</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/collections">1</a>'
  When I am logged in as a super admin
    And I go to the collections page
  Then I should see the text with tags '<a href="/collections/Item_Counts/works">3</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">2</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/collections">1</a>'
  When I log out
    And I go to the collections page
  Then I should see the text with tags '<a href="/collections/Item_Counts/works">1</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">1</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/collections">1</a>'
  When I am logged in as the owner of "Item Counts"
    And I post the work "Public 2" in the collection "Item Counts"
    And I bookmark the work "Public 2" to the collection "Item Counts"
    And the collection "Sub Count" is deleted
    And all indexing jobs have been run
    And I go to the collections page
  Then I should see the text with tags '<a href="/collections/Item_Counts/works">4</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">3</a>'
    And I should not see "Challenges/Subcollections:" within ".stats"
  When I am logged in as a super admin
    And I go to the collections page
  Then I should see the text with tags '<a href="/collections/Item_Counts/works">4</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">3</a>'
    And I should not see "Challenges/Subcollections:" within ".stats"
  When I log out
    And I go to the collections page
    Then I should see the text with tags '<a href="/collections/Item_Counts/works">2</a>'
    And I should see the text with tags '<a href="/collections/Item_Counts/bookmarks">2</a>'
    And I should not see "Challenges/Subcollections:" within ".stats"

  Scenario: Collection tags are shown, but only for the top-level collection

  Given a set of collections for searching
  When I am logged in as the owner of "Some Test Collection"
    And I set up the collection "Subcollection"
    And I fill in "collection_parent_name" with "sometest"
    And I fill in "collection_tag_string" with "Subcollection Only"
    And I press "Submit"
    And all indexing jobs have been run
    And I go to the collections page
    And I fill in "collection_search_title" with "Some Test Collection"
    And I press "Sort and Filter"
  Then I should see "The Best Tag" within ".tags"
    And I should see "The Better Tag" within ".tags"
    But I should not see "Subcollection Only"
  When I follow "Some Test Collection"
    And I follow "Profile"
  Then I should see "The Best Tag" within ".tags"
    And I should see "The Better Tag" within ".tags"
    But I should not see "Subcollection Only"
