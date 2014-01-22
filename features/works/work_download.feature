# encoding=utf-8

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
  When I follow "MOBI"
  Then I should receive a file of type "mobi"
  When I go to the work page with title "Has double quotes"
    And I follow "PDF"
  Then I should receive a file of type "pdf"
  When I go to the work page with title "Has double quotes"
    And I follow "EPUB"
  Then I should receive a file of type "epub"
  
  
  
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
  
  
  Scenario: Download of chaptered works includes chapters
  
  Given the chaptered work "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should see "Chapter 2"
  
  
  Scenario: It should be possible to download chaptered works
  
  Given I am logged in as "author"
  When I post the chaptered work "Epic Novel"
  Then I should be able to download all versions of "Epic Novel"
  
    
  Scenario: downloads expire after chapters are added
  
  Given I am logged in as "author"
    And I post the work "NaNoWriMo"
    And I download the mobi version of "NaNoWriMo"
  Then the mobi version of "NaNoWriMo" should exist
  When a chapter is added to "NaNoWriMo"
  Then the mobi version of "NaNoWriMo" should not exist
  
  Scenario: downloads expire after a work is added to a series
  
  Given I am logged in as "author"
    And I post the work "NaNoWriMo"
    And I download the mobi version of "NaNoWriMo"
  Then the mobi version of "NaNoWriMo" should exist
  When I add "NaNoWriMo" to the series "Whatever"
  Then the mobi version of "NaNoWriMo" should not exist
  
  Scenario: downloads do not expire after a different work is added to the same series
  
  Given I am logged in as "author"
    And I add "Something" to the series "Whatever"
    And I download the mobi version of "Something"
  Then the mobi version of "Something" should exist
  When I add "Another Series Story" to the series "Whatever"
  Then the mobi version of "Something" should exist
  
  Scenario: works cannot be downloaded if unrevealed
  
  Given I am logged in as "author"
    And I create the unrevealed collection "Unrevealed"
    And I post the work "Blabla"
    And I add my work to the collection "Unrevealed"
  Then I should not be able to download the mobi version of "Blabla"
    And I should see "can't download an unrevealed"
    
  Scenario: works cannot be downloaded if we don't support the type
  
  Given I am logged in as "author"
    And I post the work "Whatever"
  Then I should not be able to manually download the foobar version of "Whatever"
    And I should see "don't support that format"
    
  Scenario: graceful error message when file can't be generated
  
  Given I am logged in as "author"
    And I post the work "Whatever"
    And I try and fail to download the mobi version of "Whatever"
  Then I should see "Please try again"
  
  Scenario: disable guest download
    
  Given I am logged in as "author"
    And I post the work "NaNoWriMo"
    And guest downloading is off
    And I am logged out as an admin
  When I view the work "NaNoWriMo"
    And I follow "PDF"
  Then I should see "Due to current high load"
  When I am logged in as a random user
  Then I should be able to download all versions of "NaNoWriMo"
    And I should not see "Due to current high load"
  
  