@works @tags
Feature: Create Works
  In order to have an archive full of works
  As an author
  I want to create new works

  Scenario: You can't create a work unless you're logged in
  When I go to the new work page
  Then I should see "Please log in"

  Scenario: Creating a new minimally valid work
    Given basic tags
      And I am logged in as "newbie"
    When I go to the new work page
    Then I should see "Post New Work"
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "All Hell Breaks Loose"
      And I fill in "content" with "Bad things happen, etc."
    When I press "Preview"
    Then I should see "Preview"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"

  Scenario: Creating a new minimally valid work and posting without preview
    Given I am logged in as "newbie"
    When I set up the draft "All Hell Breaks Loose" 
      And I fill in "content" with "Bad things happen, etc."
      And I press "Post Without Preview"
    Then I should see "Work was successfully posted."
      And I should see "Bad things happen, etc."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"

  Scenario: Creating a new minimally valid work when you have more than one pseud
    Given I am logged in as "newbie"      
      And "newbie" creates the pseud "Pointless Pseud"
    When I set up the draft "All Hell Breaks Loose"
      And I unselect "newbie" from "work_author_attributes_ids_"
      And I select "Pointless Pseud" from "work_author_attributes_ids_"
      And I press "Post Without Preview"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"
      And I should see "by Pointless Pseud"

  Scenario: Creating a new work with everything filled in, and we do mean everything
    Given basic tags
      And the following activated users exist
        | login          | password    | email                 |
        | coauthor       | something   | coauthor@example.org  |
        | cosomeone      | something   | cosomeone@example.org |
        | giftee         | something   | giftee@example.org    |
        | recipient      | something   | recipient@example.org |
      And I have a collection "Collection 1" with name "collection1"
      And I have a collection "Collection 2" with name "collection2"
      And I am logged in as "thorough" with password "something"
      And "thorough" creates the pseud "Pseud2"
      And "thorough" creates the pseud "Pseud3"
      And all emails have been delivered
    When I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I check "F/M"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "All Something Breaks Loose"
      And I fill in "content" with "Bad things happen, etc."
      And I check "front-notes-options-show"
      And I fill in "work_notes" with "This is my beginning note"
      And I fill in "work_endnotes" with "This is my endingnote"
      And I fill in "Summary" with "Have a short summary"
      And I fill in "Characters" with "Sam Winchester, Dean Winchester,"
      And I fill in "Relationships" with "Harry/Ginny"
      And I fill in "Additional Tags" with "An extra tag"
      And I fill in "Gift this work to" with "Someone else, recipient"
      And I check "series-options-show"
      And I fill in "work_series_attributes_title" with "My new series"
      And I select "Pseud2" from "work_author_attributes_ids_"
      And I select "Pseud3" from "work_author_attributes_ids_"
      And I fill in "pseud_byline" with "coauthor"
      And I fill in "Post to Collections / Challenges" with "collection1, collection2"
      And I press "Preview"
    Then I should see "Draft was successfully created"
    When I press "Post"
    Then I should see "Work was successfully posted."
      And 2 emails should be delivered to "coauthor@example.org"
      And the email should contain "You have been listed as a co-creator on the following work"
      And the email should not contain "translation missing"
      And 1 email should be delivered to "recipient@example.org"
      And the email should contain "A gift work has been posted for you"
    When I go to the works page
    Then I should see "All Something Breaks Loose"
    When I follow "All Something Breaks Loose"
    Then I should see "All Something Breaks Loose"
      And I should see "Fandom: Supernatural"
      And I should see "Rating: Not Rated"
      And I should see "No Archive Warnings Apply"
      And I should not see "Choose Not To Use Archive Warnings"
      And I should see "Category: F/M"
      And I should see "Characters: Sam Winchester, Dean Winchester"
      And I should see "Relationship: Harry/Ginny"
      And I should see "Additional Tags: An extra tag"
      And I should see "For Someone else, recipient"
      And I should see "Collections: Collection 1, Collection 2"
      And I should see "Notes"
      And I should see "This is my beginning note"
      And I should see "See the end of the work for more notes"
      And I should see "This is my endingnote"
      And I should see "Summary"
      And I should see "Have a short summary"
      And I should see "Pseud2" within ".byline"
      And I should see "Pseud3" within ".byline"
      And I should see "My new series"
      And I should see "Bad things happen, etc."
    When I follow "Add Chapter"
      And I fill in "Chapter Title" with "This is my second chapter"
      And I fill in "content" with "Let's write another story"
      And I press "Preview"
    Then I should see "Chapter 2: This is my second chapter"
      And I should see "Let's write another story"
    When I press "Post"
    Then I should see "All Something Breaks Loose"
      And I should not see "Bad things happen, etc."
      And I should see "Let's write another story"
    When I follow "Previous Chapter"
      And I should see "Bad things happen, etc."
    When I follow "Entire Work"
    Then I should see "Bad things happen, etc."
      And I should see "Let's write another story"
    When I follow "Edit"
      And I check "co-authors-options-show"
      And I fill in "pseud_byline" with "Does_not_exist"
      And I press "Preview"
    Then I should see "Please verify the names of your co-authors"
      And I should see "These pseuds are invalid: Does_not_exist"
    When all emails have been delivered
      And I fill in "pseud_byline" with "cosomeone"
    When "autocomplete tests with JavaScript" is fixed
#      Then I should see "cosomeone" in the autocomplete
    When I press "Preview"
      And I press "Update"
    Then I should see "Work was successfully updated"
      And I should see "cosomeone" within ".byline"
      And I should see "coauthor" within ".byline"
      And I should see "Pseud2" within ".byline"
      And I should see "Pseud3" within ".byline"
      And 1 email should be delivered to "cosomeone@example.org"
    When all emails have been delivered
      And I follow "Edit"
      And I give the work to "giftee"
      And I press "Preview"
      And I press "Update"
    Then I should see "Work was successfully updated"
      And I should see "For giftee"
      And 1 email should be delivered to "giftee@example.org"
    When I go to giftee's user page
    Then I should see "Gifts (1)"

  Scenario: Creating a new work with some maybe-invalid things
  # TODO: needs some more actually invalid things as well
    Given basic tags
      And the following activated users exist
        | login          | password    | email                   |
        | coauthor       | something   | coauthor@example.org |
        | badcoauthor    | something   | badcoauthor@example.org |
      And I am logged in as "thorough" with password "something"
      And user "badcoauthor" is banned
    When I set up the draft "Bad Draft"
      And I fill in "Fandoms" with "Invalid12./"
      And I fill in "Work Title" with "/"
      And I fill in "content" with "T"
      And I check "chapters-options-show"
      And I fill in "work_wip_length" with "text"
      And I press "Preview"
    Then I should see "Brevity is the soul of wit, but your content does have to be at least 10 characters long."
    When I fill in "content" with "Text and some longer text"
      And I fill in "work_collection_names" with "collection1, collection2"
      And I press "Preview"
    Then I should see "Sorry! We couldn't save this work because:"
      And I should see a collection not found message for "collection1"
    # Collections are now parsed by collectible.rb which only shows the first failing collection and nothing else
    # And I should see a collection not found message for "collection2"
    When I fill in "work_collection_names" with ""
      And I fill in "pseud_byline" with "badcoauthor"
      And I press "Preview"
    Then I should see "badcoauthor is currently banned"
    When I fill in "pseud_byline" with "coauthor"
      And I fill in "Additional Tags" with "this is a very long tag more than one hundred characters in length how would this normally even be created"
      And I press "Preview"
    Then I should see "try using less than 100 characters or using commas to separate your tags"
    When I fill in "Additional Tags" with "this is a shorter tag"
      And I press "Preview"
    Then I should see "Draft was successfully created"
      And I should see "Chapter"
      And I should see "1/?"

  Scenario: test for integer title and multiple fandoms
    Given I am logged in
    When I set up the draft "02138"
      And I fill in "Fandoms" with "Supernatural, Smallville"
    When I press "Post Without Preview"
    Then I should see "Work was successfully posted."
      And I should see "Supernatural"
      And I should see "Smallville"
      And I should see "02138" within "h2.title"

  Scenario: test for < and > in title
    Given I am logged in
    When I set up the draft "4 > 3 and 2 < 5"
    When I press "Post Without Preview"
    Then I should see "Work was successfully posted."
      And I should see "4 > 3 and 2 < 5" within "h2.title"

  Scenario: posting a chapter without preview
    Given I am logged in as "newbie" with password "password"
      And I post the work "All Hell Breaks Loose"
    When I follow "Add Chapter"
      And I fill in "Chapter Title" with "This is my second chapter"
      And I fill in "content" with "Let's write another story"
      And I press "Post Without Preview"
    Then I should see "Chapter 2: This is my second chapter"
      And I should see "Chapter has been posted!"
      And I should not see "This is a preview"

  Scenario: RTE and HTML buttons are separate
  Given the default ratings exist
    And I am logged in as "newbie"
  When I go to the new work page
  Then I should see "Post New Work"
    And I should see "Rich Text" within ".rtf-html-switch"
    And I should see "HTML" within ".rtf-html-switch"
    
  Scenario: posting a backdated work
  Given I am logged in as "testuser" with password "testuser"
    And I post the work "This One Stays On Top"
    And I set up the draft "Backdated"
    And I check "backdate-options-show"
    And I select "1" from "work_chapter_attributes_published_at_3i"
    And I select "January" from "work_chapter_attributes_published_at_2i"
    And I select "1990" from "work_chapter_attributes_published_at_1i"
    And I press "Preview"
  When I press "Post"
  Then I should see "Published:1990-01-01"
  When I go to the works page
  Then "This One Stays On Top" should appear before "Backdated"
        
  Scenario: Users must set something as a warning and Author Chose Not To Use Archive Warnings should not be added automatically
    Given basic tags
      And I am logged in
    When I go to the new work page
      And I fill in "Fandoms" with "Dallas"
      And I fill in "Work Title" with "I Shot J.R.: Kristin's Story"
      And I fill in "content" with "It wasn't my fault, you know."
      And I press "Post Without Preview"
    Then I should see "We couldn't save this work"
      And I should see "Please add all required tags. Warning is missing."
    When I check "No Archive Warnings Apply"
      And I press "Post Without Preview"
    Then I should see "Work was successfully posted."
      And I should see "No Archive Warnings Apply"
      And I should not see "Author Chose Not To Use Archive Warnings"
      And I should see "It wasn't my fault, you know."

  Scenario: Users can co-create a work with a co-creator who has multiple pseuds
    Given basic tags
      And "myself" has the pseud "Me"
      And "herself" has the pseud "Me"
    When I am logged in as "testuser" with password "testuser"
      And I go to the new work page
      And I fill in the basic work information for "All Hell Breaks Loose"
      And I check "co-authors-options-show"
      And I fill in "pseud_byline" with "Me"
      And I press "Post Without Preview"
   Then I should see "There's more than one user with the pseud Me. Please choose the one you want:"
      And I select "myself" from "work[author_attributes][ambiguous_pseuds][]"
      And I press "Preview"
   Then I should see "Draft was successfully created."
      And I press "Post"
   Then I should see "Work was successfully posted. It should appear in work listings within the next few minutes."
      And I should see "Me (myself), testuser"

  Scenario: Users can't set a publication date that is in the future, e.g. set 
  the date to April 30 when it is April 26
    Given I am logged in
      And it is currently Wed Apr 26 22:00:00 UTC 2017
      And I set up a draft "Futuristic"
    When I check "Set a different publication date"
      And I select "30" from "work[chapter_attributes][published_at(3i)]"
      And I press "Post Without Preview"
    Then I should see "Publication date can't be in the future."
    When I jump in our Delorean and return to the present
