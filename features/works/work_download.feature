# encoding=utf-8

@works

Feature: Download a work
  @wip
  Scenario: Download an ordinary work

  Given the work "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
  Then I should see the text with tags "Tittle%20with%20doubble%20letters.mobi"
  When I follow "MOBI"
  Then I should see "Tittle with doubble letters"
    And I should see the text with tags "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "PDF"
  # Then...
  When I view the work "Tittle with doubble letters"
    And I follow "HTML"
  Then I should see "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "EPUB"
  # Then...

  @wip
  Scenario: Download works with quotation marks in the title doesn't bomb

  Given I am logged in as a random user
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      "Has double quotes"
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  # Then...
  When I go to the work page with title "Has double quotes"
    And I follow "PDF"
  # Then...
  When I go to the work page with title "Has double quotes"
    And I follow "HTML"
  # Then...
  When I go to the work page with title "Has double quotes"
    And I follow "EPUB"
  # Then...

  @wip
  Scenario: Download works with Cyrillic in the title doesn't bomb

  Given I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      Первый_маг
      """
  When I press "Post Without Preview"
  # TODO: Think about whether we can invent a better name than this
  Then I should see the text with tags "_.mobi"
  When I follow "MOBI"
  # Then...
  When I go to the work page with title Первый_маг
    And I follow "PDF"
  # Then...
  When I go to the work page with title Первый_маг
    And I follow "HTML"
  # Then...
  When I go to the work page with title Первый_маг
    And I follow "EPUB"
  # Then...

  @wip
  Scenario: Download works with curly quotes in the title doesn't bomb

  Given I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      Has curly’d quotes
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  # Then...
  When I go to the work page with title Has curly’d quotes
    And I follow "PDF"
  # Then...
  When I go to the work page with title Has curly’d quotes
    And I follow "HTML"
  # Then...
  When I go to the work page with title Has curly’d quotes
    And I follow "EPUB"
  # Then...

  @wip
  Scenario: Download works with curly and straight quotes and accented 
  characters in the title doesn't bomb

  Given I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      "Hàs curly’d quotes"
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  # Then...
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "PDF"
  # Then...
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "HTML"
  # Then...
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "EPUB"
  # Then...

  @wip
  Scenario: Download chaptered works doesn't bomb
 
  Given the chaptered work "Epic Novel"
  When I view the work "Epic Novel"
    And I follow "HTML"
  Then I should see "Epic Novel"
    And I should see "Another Chapter"
    And I should not see "Comments"
  When I view the work "Epic Novel"
    And I follow "PDF"
  # Then...
  When I view the work "Epic Novel"
    And I follow "MOBI"
  # Then...
  When I view the work "Epic Novel"
    And I follow "EPUB"

  @wip
  Scenario: Download MOBI and PDF for works with unusual characters in the title

  Given I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      ♥ and é Türkçe Karakterler başlıkta nasıl görünüyor
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  # Then...
  When I go to the work page with title ♥ and é Türkçe Karakterler başlıkta nasıl görünüyor
    And I follow "PDF"
  # Then...

  @wip
  Scenario: Download MOBI and PDF for works with more unusual characters in the title

  Given I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      à ø something
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  # Then...
  When I go to the work page with title à ø something
    And I follow "PDF"
  # Then...

  Scenario: Download chaptered works as HTML

  Given the chaptered work "Bazinga"
  When I view the work "Bazinga"
    And I follow "HTML"
  Then I should see "Chapter 2"

  Scenario: Unrevealed works cannot be downloaded

  Given there is a work "Now You See Me" in an unrevealed collection "Invisibility"
  When I am logged in as the owner of "Invisibility"
    And I view the work "Now You See Me"
    And I follow "HTML"
    And "AO3-4706" is fixed
  # Then I should see "Sorry, you can't download an unrevealed work"
  #   And I should be on the works page
