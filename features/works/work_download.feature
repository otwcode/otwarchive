@works
Feature: Download a work

  Scenario: Download a work in various formats

  Given I am logged in as "myname"
    And I post the work "Tittle with doubble letters"
  Then I should be able to download all versions of "Tittle with doubble letters"


  Scenario: Download works with double quotes in title

  Given I am logged in as "myname"
    And I set up the draft "Foo"
    And I fill in "Work Title" with
        """
        "Has double quotes"
        """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
    And I follow "PDF"
  Then I should receive a file of type "pdf"
  When I go to the work page with title "Has double quotes"
    And I follow "MOBI"
  Then I should receive a file of type "mobi"
  When I go to the work page with title "Has double quotes"
    And I follow "EPUB"
  Then I should receive a file of type "epub"
  When I go to the work page with title "Has double quotes"
    And I follow "AZW3"
  Then I should receive a file of type "azw3"
  When I go to the work page with title "Has double quotes"
    And I follow "HTML"
  Then I should receive a file of type "html"
	  And the page title should include '"Has double quotes"'


  Scenario: Download works with non-ASCII characters in title

  Given I am logged in as "myname"
  When I post the work "Первый_маг"
  Then I should be able to download all versions of "Первый_маг"
  When I post the work "Hàs curly’d quotes"
  Then I should be able to download all versions of "Hàs curly’d quotes"
  When I post the work "♥ é Türkçe Karakterler başlıkta nasıl görünüyor"
  Then I should be able to download all versions of "♥ é Türkçe Karakterler başlıkta nasıl görünüyor"
  When I post the work "à ø something"
  Then I should be able to download all versions of "à ø something"
  When I post the work "流亡在阿尔比恩"
  Then I should be able to download all versions of "流亡在阿尔比恩"
  When I post the work "-dash in title-"
  Then I should be able to download all versions of "-dash in title-"
  When I post the work "Emjoi 🤩 Yay 🥳"
  Then I should be able to download all versions of "Emjoi 🤩 Yay 🥳"


  Scenario: Downloaded work header contains expected meta fields in expected order

  Given basic tags
    And I have a collection "My Collection 1" with name "mycollection1"
    And I have a collection "My Collection 2" with name "mycollection2"
    And I am logged in
    And I go to the new work page
    And I select "General" from "Rating"
    And I check "No Archive Warnings Apply"
    And I check "Gen"
    And I fill in "Fandoms" with "Cool Fandom"
    And I fill in "Characters" with "Character 1, Character 2, Character 3"
    And I fill in "Relationships" with "Character 1/Character 2, Character 1 & Character 3"
    And I fill in "Additional Tags" with "Modern AU"
    And I set the publication date to 10 January 2015
    And I check "This work is part of a series"
    And I fill in "Or create and use a new one:" with "THE DOWN"
    And I fill in "Post to Collections / Challenges" with "mycollection1, mycollection2"
    And I fill in "Work Title" with "Downloadable"
    And I fill in "content" with "Could be downloaded"
    And I select "English" from "Choose a language"
    And I press "Post"
    And I follow "Add Chapter"
    And I fill in "content" with "Remember, remember the 5th of November"
    And I set the publication date to 5 November 2020
    And I press "Post"
  When I view the work "Downloadable"
    And I follow "HTML"
  Then I should see "Downloadable"
    And I should see "Rating: General Audiences"
    And I should see "Archive Warning: No Archive Warnings Apply"
    And I should see "Category: Gen"
    And I should see "Fandom: Cool Fandom"
    And I should see "Relationships: Character 1/Character 2, Character 1 & Character 3"
    And I should see "Characters: Character 1, Character 2, Character 3"
    And I should see "Additional Tags: Modern AU"
    And I should see "Language: English"
    And I should see "Series: Part 1 of THE DOWN"
    And I should see "Collections: My Collection 1, My Collection 2"
    And I should see "Published: 2015-01-10"
    And I should see "Completed: 2020-11-05"
    And I should see "Words: 9"
    And I should see "Chapters: 2/2"
    And "Rating:" should appear before "Archive Warning"
    And "Archive Warning:" should appear before "Category"
    And "Category:" should appear before "Fandom"
    And "Fandom:" should appear before "Relationship"
    And "Relationships:" should appear before "Character"
    And "Characters:" should appear before "Additional Tags"
    And "Additional Tags:" should appear before "Language"
    And "Language:" should appear before "Series"
    And "Series:" should appear before "Collections"
    And "Collections:" should appear before "Published"
    And "Published:" should appear before "Completed"
    And "Completed:" should appear before "Chapters"
    And "Words:" should appear before "Chapters:"
    And "Chapters:" should appear before "Could be downloaded"

  Scenario: Downloaded work afterword does not mention author

  Given the work "Downloadable"
  When I view the work "Downloadable"
    And I follow "HTML"
  Then I should not see "to let the author know if you enjoyed"
    But I should see "to let the creator know if you enjoyed"

  Scenario: Download of chaptered works includes chapters

  Given the chaptered work "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should see "Chapter 2"

  Scenario: Download of chaptered work without posted chapters does not include chapters

  Given the work "Bazinga"
    And a draft chapter is added to "Bazinga"
    And I delete chapter 1 of "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should not see "Chapter 1"
    And I should not see "Chapter 2"
    And I should be able to download all versions of "Bazinga"

  Scenario: Download chaptered works

  Given I am logged in as "author"
  When I post the chaptered work "Epic Novel"
  Then I should be able to download all versions of "Epic Novel"


  Scenario: Works can be downloaded when anonymous

  Given there is a work "Test Work" in an anonymous collection "Anonymous"
  When I am a visitor
    And I view the work "Test Work"
    And I follow "HTML"
  Then I should see "Anonymous"
    And I should be able to download all versions of "Test Work"


  Scenario: Multifandom works can be downloaded

  Given I am logged in
    And I set up the draft "Many Fandom Work"
    And I fill in "Fandoms" with "Fandom 1, Fandom 2, Fandom 3, Fandom 4"
    And I press "Post"
  When I log out
    And I view the work "Many Fandom Work"
    And I follow "HTML"
  Then the page title should include "Multifandom"
    And I should be able to download all versions of "Many Fandom Work"


  Scenario: Download work shows inspiring work link

    Given I have related works setup
    When I post a related work as remixer
      And I view the work "Followup"
      And I follow "HTML"
    Then I should see the inspiring parent work link

  Scenario: Download work shows inspiring external inspiring work link

    Given I have related works setup
    When I post a related work as remixer for an external work
      And I view the work "Followup"
      And I follow "HTML"
    Then I should see the external inspiring work link


  Scenario: Download option is unavailable if work is unrevealed.

  Given there is a work "Blabla" in an unrevealed collection "Unrevealed"
    And I am logged in as the author of "Blabla"
  Then I should not see "Download"


  Scenario: Download option is unavailable if work is unposted.

  Given I am logged in
    And the draft "Unposted Work"
  When I view the work "Unposted Work"
  Then I should not see "Download"


  Scenario: Download option is unavailable if work is hidden by admin.

  Given I am logged in
    And I post the work "TOS Violation"
  When I am logged in as a "policy_and_abuse" admin
    And I hide the work "TOS Violation"
  Then I should not see "Download"

  Scenario: Downloads of related work update when parent work's anonymity changes.

  Given a hidden collection "Hidden"
    And I have related works setup
    And I post a related work as remixer
    And I post a translation as translator
    And I log out
  When I view the work "Followup"
    And I follow "HTML"
  Then I should see "Worldbuilding by inspiration"
  When I view the work "Worldbuilding Translated"
    And I follow "HTML"
  Then I should see "Worldbuilding by inspiration"
  # Going from revealed to unrevealed
  When I am logged in as "inspiration"
    And I edit the work "Worldbuilding" to be in the collection "Hidden"
    And I log out
    And I view the work "Followup"
    And I follow "HTML"
  Then I should not see "inspiration"
    And I should see "Inspired by a work in an unrevealed collection"
  When I view the work "Worldbuilding Translated"
    And I follow "HTML"
  Then I should not see "inspiration"
    And I should see "A translation of a work in an unrevealed collection"
  # Going from unrevealed to revealed
  When I reveal works for "Hidden"
    And I log out
    And I view the work "Followup"
    And I follow "HTML"
  Then I should see "Worldbuilding by inspiration"
  When I view the work "Worldbuilding Translated"
    And I follow "HTML"
  Then I should see "Worldbuilding by inspiration"

  Scenario: Downloads of related work update when child work's anonymity changes.

  Given a hidden collection "Hidden"
    And I have related works setup
    And a related work has been posted and approved
  When I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "Followup by remixer"
    And I should not see "A work in an unrevealed collection"
  # Going from revealed to unrevealed
  When I am logged in as "remixer"
    And I edit the work "Followup" to be in the collection "Hidden"
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should not see "Followup by remixer"
    And I should see "A work in an unrevealed collection"
  # Going from unrevealed to revealed
  When I reveal works for "Hidden"
    And I log out
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "Followup by remixer"
    And I should not see "A work in an unrevealed collection"

  Scenario: Downloads hide titles of restricted related works

  Given I have related works setup
    And a related work has been posted and approved
    And I am logged in as "remixer"
    And I lock the work "Followup"
  When I am logged out
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "[Restricted Work] by remixer"
  When I am logged in as "inspiration"
    And I lock the work "Worldbuilding"
    And I am logged in as "remixer"
    And I unlock the work "Followup"
    And I am logged out
    And I view the work "Followup"
    And I follow "HTML"
  Then I should see "Inspired by [Restricted Work] by inspiration"

  Scenario: Downloads of translated work update when translation's revealed status changes.

  Given a hidden collection "Hidden"
    And I have related works setup
    And a translation has been posted and approved
    And I log out
  When I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "Worldbuilding Translated by translator"
  # Going from revealed to unrevealed
  When I am logged in as "translator"
    And I edit the work "Worldbuilding Translated" to be in the collection "Hidden"
    And I log out
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should not see "Worldbuilding Translated by translator"
    And I should see "A work in an unrevealed collection"
  # Going from unrevealed to revealed
  When I reveal works for "Hidden"
    And I log out
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "Worldbuilding Translated by translator"

  Scenario: Downloads hide titles of restricted work translations

  Given I have related works setup
    And a translation has been posted and approved
    And I am logged in as "translator"
    And I lock the work "Worldbuilding Translated"
  When I am logged out
    And I view the work "Worldbuilding"
    And I follow "HTML"
  Then I should see "[Restricted Work] by translator"
