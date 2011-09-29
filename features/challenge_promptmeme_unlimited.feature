@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Check the autocomplete is working
  
    Given I have standard challenge tags setup
      And I am logged in as "mod1"
    When I set up a basic promptmeme "Battle 12"
      And I follow "Challenge Settings"
      And I should see "Setting Up The Battle 12 Prompt Meme"
    When I fill in "prompt_meme_request_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate Atlantis, Stargate SG-1"
      And I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"
      And I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"
      And I fill in "prompt_meme_request_restriction_attributes_character_num_allowed" with "2"
      And I check "prompt_meme_request_restriction_attributes_character_restrict_to_fandom"
      And I fill in "prompt_meme_requests_num_allowed" with "50"
      And I fill in "prompt_meme_requests_num_required" with "2"
      And I check "Signup open?"
      And I press "Update"
    
    # check the autocomplete is working; the tag is not connected to the fandom, so remove it after that
  
    When I am logged in as "myname1"
    When I go to "Battle 12" collection's page
      And I follow "Sign Up"
      And I check the 1st checkbox with the value "Stargate Atlantis"
      And I fill in the 1st field with id matching "character_tagnames" with "John"
    Then I should see "John Sheppard" in the autocomplete
  
    # check the autocomplete is working for the single prompt add form
  
    When I fill in the 1st field with id matching "character_tagnames" with ""
      And I check the 1st checkbox with the value "Stargate Atlantis"
      And I press "Submit"
    When I follow "Add another prompt"
    When I check the 2nd checkbox with the value "Stargate Atlantis"
      And I fill in the 2nd field with id matching "character_tagnames" with "John"
    Then I should see "John Sheppard" in the autocomplete


  Scenario: Create a prompt meme for a large challenge like bigger memes

  Given I have standard challenge tags setup
    And I am logged in as "mod1"
  When I set up a basic promptmeme "Battle 12"
    And I follow "Challenge Settings"
  When I fill in unlimited prompt challenge options
  Then I should see "Challenge was successfully updated"
    
  # sign up as first user
  
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination D
  When I add prompt 3
  When I add prompt 4
  When I add prompt 5
  When I add prompt 6
  When I add prompt 7
  When I add prompt 8
  When I add prompt 9
  When I add prompt 10
  When I add prompt 11
  When I add prompt 12
  
  # second user creates another load of prompts
  
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I sign up for Battle 12 with combination D
    And I add 34 prompts
  Then I should see "Signup was successfully updated"
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
    And I press "Claim"
  Then I should see "New claim made."
  
  # 3rd user creates some more prompts
  
  When I follow "Log out"
    And I am logged in as "myname3" with password "something"
  When I sign up for Battle 12 with combination D
    And I add 24 prompts
    And I add prompt 25 with SG-1
  Then I should see "Signup was successfully updated"
  
  # filter by fandom
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "Stargate Atlantis" within "table"
    And I should see "Stargate SG-1" within "table"
  When I sort by fandom
  Then I should see "Stargate Atlantis" within "table"
    And I should not see "Stargate SG-1" within "table"
  When I sort by fandom
  Then I should see "Stargate Atlantis" within "table"
    And I should see "Stargate SG-1" within "table"
