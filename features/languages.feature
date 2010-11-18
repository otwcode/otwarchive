@works
Feature: Languages
    
  Scenario: Browse works by language
  
  # Admin set up the language
  
  Given the following admin exists
      | login       | password |
      | Zooey       | secret   |
  When I go to the admin_login page
    And I fill in "admin_session_login" with "Zooey"
    And I fill in "admin_session_password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in" 
  When I follow "settings"
  # TODO: Then I should be able to add a language in the front end
  When I follow "Log out"
  Then I should see "Successfully logged out"
  
  # post a work in that language
  
  Given the following activated users exist
      | login         | password   |
      | englishuser   | password   |
      | germanuser1   | password   |
      | germanuser2   | password   |
      | frenchuser    | password   |
      And I am logged in as "germanuser1" with password "password"
      And basic tags
      And basic languages
  Then I should see "Hi, germanuser1!"
  When I follow "Log out"
  Then I should see "logged out"
  When I am logged in as "germanuser2" with password "password"
    And I post the work "Die Rache der Sith"
    And I follow "Edit"
    And I select "Deutsch" from "Choose a language"
    And I press "Preview"
    And I press "Update"
  Then I should see "Die Rache der Sith"
  
  # TODO: French including sedilla, other characters not in the ascii set.
  
  When I follow "Log out"
    And I am logged in as "englishuser" with password "password"
    And I post the work "Revenge of the Sith"
  Then I should see "Revenge of the Sith"
    
  # Browse works in a language
  
  When I am on the languages page
  Then I should see "Deutsch"
  When I follow "Deutsch"
  Then I should see "1 works in 1 fandoms"
    And I should see "Die Rache der Sith"
    And I should not see "Revenge of the Sith"
    
  # cross-check in English
    
  When I am on the languages page
  Then I should see "English"
    And I should see the text with tags "<td>English</td>"
    And I should see the text with tags "<td><a href="/works">1</a></td>"
