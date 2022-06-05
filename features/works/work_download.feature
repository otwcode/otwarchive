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


  Scenario: Download of chaptered works includes chapters

  Given the chaptered work "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should see "Chapter 2"


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
