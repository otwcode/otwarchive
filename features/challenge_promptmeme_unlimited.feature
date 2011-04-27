@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Check the autocomplete is working
  
  Given basic tags
    And I create the fandom "Stargate Atlantis" with id 54
    And I create the fandom "Stargate SG-1" with id 55
    And a character exists with name: "John Sheppard", canonical: true
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
    And I press "Submit"
    
  # check the autocomplete is working; the tag is not connected to the fandom, so remove it after that
  
  When I am logged in as "myname1"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_54"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John"
  Then I should find "John Sheppard" within "div.auto_complete"
  
  # check the autocomplete is working for the single prompt add form
  
  When I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with ""
    And I check "challenge_signup_requests_attributes_1_fandom_54"
    And I press "Submit"
  When I follow "Add another prompt"
  When I check "challenge_signup_requests_attributes_2_fandom_54"
    And I fill in "challenge_signup_requests_attributes_2_tag_set_attributes_character_tagnames" with "John"
  Then I should find "John Sheppard" within "div.auto_complete"

  Scenario: Create a prompt meme for a large challenge like bigger kink memes

  Given basic tags
    And I create the fandom "Stargate Atlantis" with id 54
    And I create the fandom "Stargate SG-1" with id 55
    And a character exists with name: "John Sheppard", canonical: true
    And I am logged in as "mod1"
  
  # set up the challenge
  
  When I set up a basic promptmeme "Battle 12"
    And I follow "Challenge Settings"
    And I should see "Setting Up The Battle 12 Prompt Meme"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "prompt_meme_request_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate Atlantis, Stargate SG-1"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "prompt_meme_request_restriction_attributes_character_num_allowed" with "2"
    And I check "prompt_meme_request_restriction_attributes_character_restrict_to_fandom"
    And I fill in "prompt_meme_requests_num_allowed" with "50"
    And I fill in "prompt_meme_requests_num_required" with "2"
    And I check "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN"
    
  # sign up as first user
  
  When I am logged in as "myname1"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_54"
    And I check "challenge_signup_requests_attributes_1_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully created"
    And I should see "Prompts (2)"
    
  # Just add one new prompt instead?  
  
  When I follow "Add another prompt"
  Then I should see "Request 3"
    And I should see "Requests (2 - 50)"
  When I check "challenge_signup_requests_attributes_2_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 4"
  
  # try to add a request without required info
  
  When I press "Submit"
  Then I should see "Request must have exactly 1 fandom tags. You currently have none."
    And I should see "Request 4"
    But I should not see "Request 1"
  When I check "challenge_signup_requests_attributes_3_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  
  # add more prompts
  
  When I follow "Add another prompt"
  Then I should see "Request 5"
  When I check "challenge_signup_requests_attributes_4_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 6"
  When I check "challenge_signup_requests_attributes_5_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 7"
  When I check "challenge_signup_requests_attributes_6_fandom_54"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I add prompt 7
  Then I should see "Signup was successfully updated"
  When I add prompt 8
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 10"
  When I check "challenge_signup_requests_attributes_9_fandom_55"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 11"
  When I check "challenge_signup_requests_attributes_10_fandom_55"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  When I follow "Add another prompt"
  Then I should see "Request 12"
  When I check "challenge_signup_requests_attributes_11_fandom_55"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  
  # second user creates another load of prompts
  
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_54"
  When I follow "Add another prompt"
    And I check "challenge_signup_requests_attributes_1_fandom_54"
    And I press "Submit"
    And I add prompt 2
    And I add prompt 3
    And I add prompt 4
    And I add prompt 5
    And I add prompt 6
    And I add prompt 7
    And I add prompt 8
    And I add prompt 9
    And I add prompt 10
    And I add prompt 11
    And I add prompt 12
    And I add prompt 13
    And I add prompt 14
    And I add prompt 15
    And I add prompt 16
    And I add prompt 17
    And I add prompt 18
    And I add prompt 19
    And I add prompt 20
    And I add prompt 21
    And I add prompt 22
    And I add prompt 23
    And I add prompt 24
    And I add prompt 25
    And I add prompt 26
    And I add prompt 27
    And I add prompt 28
    And I add prompt 29
    And I add prompt 30
    And I add prompt 31
    And I add prompt 32
    And I add prompt 33
    And I add prompt 34
  Then I should see "Signup was successfully updated"
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
    And I press "Claim"
  Then I should see "New claim made."
  
  # 3rd user creates some more prompts
  
  When I follow "Log out"
    And I am logged in as "myname3" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_54"
  When I follow "Add another prompt"
    And I check "challenge_signup_requests_attributes_1_fandom_54"
    And I press "Submit"
    And I add prompt 2
    And I add prompt 3
    And I add prompt 4
    And I add prompt 5
    And I add prompt 6
    And I add prompt 7
    And I add prompt 8
    And I add prompt 9
    And I add prompt 10
    And I add prompt 11
    And I add prompt 12
    And I add prompt 13
    And I add prompt 14
    And I add prompt 15
    And I add prompt 16
    And I add prompt 17
    And I add prompt 18
    And I add prompt 19
    And I add prompt 20
    And I add prompt 21
    And I add prompt 22
    And I add prompt 23
    And I add prompt 24
  Then I should see "Signup was successfully updated"
  
  # filter by fandom
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "Stargate Atlantis" within "table"
    And I should not see "Stargate SG-1" within "table"
  When I sort by fandom
  # TODO: Figure out why this still fails
  # Then I should see "Stargate Atlantis" within "table"
  #   And I should not see "Stargate SG-1" within "table"
  # When I sort by fandom
  # Then I should see "Stargate Atlantis" within "table"
  #   And I should see "Stargate SG-1" within "table"
    
      # When I filter to fandom "Stargate Atlantis"
