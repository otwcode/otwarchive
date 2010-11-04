# encoding utf-8

@works
Feature: Download a work

  Scenario: Download works with funky titles

  Given basic tags
    And I am logged in as "myname" with password "something"
  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      "Has double quotes"
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "Mobi"
  When I go to the work page with title "Has double quotes"
  When I follow "PDF"
  When I go to the work page with title "Has double quotes"
  When I follow "HTML"
  When I go to the work page with title "Has double quotes"
  When I follow "Epub"
  
  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      Первый_маг
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "Mobi"
  When I go to the work page with title Первый_маг
  When I follow "PDF"
  When I go to the work page with title Первый_маг
  When I follow "HTML"
  When I go to the work page with title Первый_маг
  When I follow "Epub"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      Has curly’d quotes
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "Mobi"
  When I go to the work page with title Has curly’d quotes
  When I follow "PDF"
  When I go to the work page with title Has curly’d quotes
  When I follow "HTML"
  When I go to the work page with title Has curly’d quotes
  When I follow "Epub"

  When I go to the new work page
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with
      """
      "Hàs curly’d quotes"
      """
    And I fill in "content" with "some random stuff"
  When I press "Preview"
    And I press "Post"
  When I follow "Mobi"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "PDF"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "HTML"
  When I go to the work page with title "Hàs curly’d quotes"
  When I follow "Epub"
