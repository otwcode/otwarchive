# encoding=utf-8

@works

Feature: Download a work
  @wip
  Scenario: Download an ordinary work
  
  Given basic tags
    And I am logged in as "myname"
  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "Tittle with doubble letters"
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  Then I should see the text with tags "Tittle%20with%20doubble%20letters.mobi"
  When I follow "MOBI"
    Then I should see "Tittle with doubble letters"
    Then I should see the text with tags "Tittle with doubble letters"
  When I go to the work page with title Tittle with doubble letters
  When I follow "PDF"
  When I go to the work page with title Tittle with doubble letters
  When I follow "HTML"
    Then I should see "Tittle with doubble letters"
  When I go to the work page with title Tittle with doubble letters
  When I follow "EPUB"
  
  @wip
  Scenario: Download works with funky titles doesn't bomb

  Given basic tags
    And I am logged in as "myname"
  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      "Has double quotes"
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "MOBI"
  When I go to the work page with title "Has double quotes"
  When I follow "PDF"
  When I go to the work page with title "Has double quotes"
  When I follow "HTML"
  When I go to the work page with title "Has double quotes"
  When I follow "EPUB"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      Первый_маг
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  # TODO: Think about whether we can invent a better name than this
  Then I should see the text with tags "_.mobi"
  When I follow "MOBI"
  When I go to the work page with title Первый_маг
  When I follow "PDF"
  When I go to the work page with title Первый_маг
  When I follow "HTML"
  When I go to the work page with title Первый_маг
  When I follow "EPUB"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      Has curly’d quotes
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "MOBI"
  When I go to the work page with title Has curly’d quotes
  When I follow "PDF"
  When I go to the work page with title Has curly’d quotes
  When I follow "HTML"
  When I go to the work page with title Has curly’d quotes
  When I follow "EPUB"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      "Hàs curly’d quotes"
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "MOBI"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "PDF"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "HTML"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "EPUB"

  @wip
  Scenario: disable guest download

  Given I am logged in as "author"
    And I post the work "NaNoWriMo"
    And I am logged out
  When I view the work "NaNoWriMo"
  Then I should see "NaNoWriMo"
    And I should see "author" within "#main"
  When I follow "HTML"
  Then I should see "NaNoWriMo"
    And I should not see "Comments"
  When guest downloading is off
    And I am logged out as an admin
  When I view the work "NaNoWriMo"
    And I follow "PDF"
  Then I should see "Due to current high load"
  When I am logged in as a random user
    And I view the work "NaNoWriMo"
  Then I should see "Comments"
  When I follow "MOBI"
  Then I should not see "Due to current high load"

  @wip
 Scenario: download chaptered works doesn't bomb
 
  Given I am logged in as "author"
    And I post the chaptered work "Epic Novel"
    And I am logged out
    And guest downloading is on
    And I am logged out as an admin
  When I view the work "Epic Novel"
  And I follow "HTML"
  Then I should see "Epic Novel"
    And I should see "Another Chapter"
    And I should not see "Comments"
  When I view the work "Epic Novel"
    And I follow "PDF"
  When I view the work "Epic Novel"
    And I follow "MOBI"
  When I view the work "Epic Novel"
    And I follow "EPUB"

  @wip
  Scenario: issue 1957

  Given basic tags
    And I am logged in as "myname"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      ♥ and é Türkçe Karakterler başlıkta nasıl görünüyor
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "MOBI"
  When I go to the work page with title ♥ and é Türkçe Karakterler başlıkta nasıl görünüyor
  When I follow "PDF"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      à ø something
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "MOBI"
  When I go to the work page with title à ø something
  When I follow "PDF"

Scenario: Download chaptered works as HTML

  Given the chaptered work "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should see "Chapter 2"
