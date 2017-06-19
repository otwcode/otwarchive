@works
Feature: Download a work

  Scenario: Download an ordinary work

  Given the work "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "MOBI"
  Then I should receive a MOBI file "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "PDF"
  Then I should receive a PDF file "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "HTML"
  Then I should see "Tittle with doubble letters"
  When I view the work "Tittle with doubble letters"
    And I follow "EPUB"
  Then I should receive an EPUB file "Tittle with doubble letters"

  Scenario: Download works with quotation marks in the title doesn't bomb

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      "Has double quotes"
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "Has double quotes"
  When I go to the work page with title "Has double quotes"
    And I follow "PDF"
  Then I should receive a PDF file "Has double quotes"
  When I go to the work page with title "Has double quotes"
    And I follow "HTML"
  Then I should see /"Has double quotes"/
  When I go to the work page with title "Has double quotes"
    And I follow "EPUB"
  Then I should receive an EPUB file "Has double quotes"

  Scenario: Download works with Cyrillic in the title doesn't bomb

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with "Первый_маг"
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "Piervyi_magh"
  When I go to the work page with title Первый_маг
    And I follow "PDF"
  Then I should receive a PDF file "Piervyi_magh"
  When I go to the work page with title Первый_маг
    And I follow "HTML"
  Then I should see "Первый_маг"
  When I go to the work page with title Первый_маг
    And I follow "EPUB"
  Then I should receive an EPUB file "Piervyi_magh"

  Scenario: Download works with curly quotes in the title doesn't bomb

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with "Has curly’d quotes"
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "Has curlyd quotes"
  When I go to the work page with title Has curly’d quotes
    And I follow "PDF"
  Then I should receive a PDF file "Has curlyd quotes"
  When I go to the work page with title Has curly’d quotes
    And I follow "HTML"
  Then I should see "Has curly’d quotes"
  When I go to the work page with title Has curly’d quotes
    And I follow "EPUB"
  Then I should receive an EPUB file "Has curlyd quotes"

  Scenario: Download works with curly and straight quotes and accented
  characters in the title doesn't bomb

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with
      """
      "Hàs curly’d quotes"
      """
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "Has curlyd quotes"
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "PDF"
  Then I should receive a PDF file "Has curlyd quotes"
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "HTML"
  Then I should see /"Hàs curly’d quotes"/
  When I go to the work page with title "Hàs curly’d quotes"
    And I follow "EPUB"
  Then I should receive an EPUB file "Has curlyd quotes"

  Scenario: Download chaptered works doesn't bomb
 
  Given the chaptered work "Epic Novel"
  When I view the work "Epic Novel"
    And I follow "HTML"
  Then I should see "Epic Novel"
    # AO3-2725: should have chapter headings
    And I should see "Chapter 2"
    And I should see "Yet another chapter."
    And I should not see "Comments"
  When I view the work "Epic Novel"
    And I follow "PDF"
  Then I should receive a PDF file "Epic Novel"
  When I view the work "Epic Novel"
    And I follow "MOBI"
  Then I should receive a MOBI file "Epic Novel"
  When I view the work "Epic Novel"
    And I follow "EPUB"
  Then I should receive an EPUB file "Epic Novel"

  Scenario: Download MOBI and PDF for works with unusual characters in the title

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with "♥ and é Türkçe Karakterler başlıkta nasıl görünüyor"
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "and e Turkce Karakterler"
  When I go to the work page with title ♥ and é Türkçe Karakterler başlıkta nasıl görünüyor
    And I follow "PDF"
  Then I should receive a PDF file "and e Turkce Karakterler"

  Scenario: Download MOBI and PDF for works with more unusual characters in the title

  Given I am logged in
    And I set up the draft "Title I'll Replace In A Sec"
    And I fill in "Work Title" with "à ø something"
  When I press "Post Without Preview"
    And I follow "MOBI"
  Then I should receive a MOBI file "a o something"
  When I go to the work page with title à ø something
    And I follow "PDF"
  Then I should receive a PDF file "a o something"

  Scenario: Unrevealed works cannot be downloaded

  Given there is a work "Now You See Me" in an unrevealed collection "Invisibility"
  When I am logged in as the owner of "Invisibility"
    And I view the work "Now You See Me"
    And I follow "HTML"
    And "AO3-4706" is fixed
  # Then I should see "Sorry, you can't download an unrevealed work"
  #   And I should be on the works page
