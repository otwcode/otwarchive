@works @tags
Feature: Delete Works
  Check that everything disappears correctly when deleting a work

  Scenario: Deleting a minimally valid work
    Given I am logged in as "newbie"
      And I post the work "All Hell Breaks Loose"
    When I delete the work "All Hell Breaks Loose"
    Then I should see "Your work All Hell Breaks Loose was deleted."
      And "newbie" should be notified by email about the deletion of "All Hell Breaks Loose"
    When I go to the works page
    Then I should not see "All Hell Breaks Loose"
    When I go to newbie's user page
    Then I should not see "All Hell Breaks Loose"

  Scenario: Deleting minimally valid work when you have more than one pseud
    Given basic tags
      And I am logged in as "newbie"
      And "newbie" creates the default pseud "Pointless Pseud"
    When I set up the draft "All Hell Breaks Loose" with fandom "Supernatural"
      And I select "Pointless Pseud" from "work_author_attributes_ids_"
      And I press "Preview"
      And I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"
    When I delete the work "All Hell Breaks Loose"
    Then I should see "Your work All Hell Breaks Loose was deleted."
      And 1 email should be delivered
      And the email should not contain "translation missing"
    When I go to the works page
    Then I should not see "All Hell Breaks Loose"
    When I go to newbie's user page
    Then I should not see "All Hell Breaks Loose"

  Scenario: Deleting a work with everything filled in, and we do mean everything
    Given basic tags
      And the following activated users exist
        | login          | password    | email                 |
        | coauthor       | something   | coauthor@example.org  |
        | cosomeone      | something   | cosomeone@example.org |
        | giftee         | something   | giftee@example.org    |
        | recipient      | something   | recipient@example.org |
      And I have a collection "Collection 1" with name "collection1"
      And I have a collection "Collection 2" with name "collection2"
      And I am logged in as "thorough"
      And I add the pseud "Pseud2"
      And I add the pseud "Pseud3"
    When I go to the new work page
      And all emails have been delivered
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
      And I fill in "Gift this work to" with "Someone else, recipient"
      And I check "series-options-show"
      And I fill in "work_series_attributes_title" with "My new series"
      And I select "Pseud2" from "work_author_attributes_ids_"
      And I select "Pseud3" from "work_author_attributes_ids_"
      And I fill in "pseud_byline" with "coauthor"
      And I fill in "work_collection_names" with "collection1, collection2"
      And I press "Preview"
    Then I should see "Preview"
    When I press "Post"
    Then I should see "Work was successfully posted."
      And 2 email should be delivered to "coauthor@example.org"
      And the email should contain "You have been listed as a co-creator"
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
      And I should see "Chapter 1"
      And I should not see "Bad things happen, etc."
      And I should see "Let's write another story"
    When I follow "Previous Chapter"
    Then I should see "Bad things happen, etc."
      And I should not see "Let's write another story"
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
    When I am logged in as "someone_else" with password "something"
      And I view the work "All Something Breaks Loose"
      And I press "Kudos"
    Then I should see "someone_else left kudos on this work!"
    When I follow "Bookmark"
      And I fill in "Notes" with "My thoughts on the work"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
    When I go to the bookmarks page
    Then I should see "All Something Breaks Loose"
    When I am logged in as "thorough" with password "something"
      And I go to giftee's user page
    Then I should see "Gifts (1)"
    When I delete the work "All Something Breaks Loose"
    Then I should see "Your work All Something Breaks Loose was deleted."
    When I go to giftee's user page
    Then I should see "Gifts (0)"
      And I should not see "All Something Breaks Loose"
    When I go to cosomeone's user page
    Then I should not see "All Something Breaks Loose"
    When I go to thorough's user page
    Then I should not see "All Something Breaks Loose"
    # This is correct behaviour - bookmark details are preserved even though the work is gone
    When I go to the bookmarks page
    Then I should not see "All Something Breaks Loose"
    When I go to someone_else's bookmarks page
    Then I should not see "All Something Breaks Loose"
      And I should see "This has been deleted, sorry!"
      And I should see "My thoughts on the work"
