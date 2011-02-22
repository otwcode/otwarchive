@collections @challenges
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it

  Scenario: Create a prompt meme for a challenge like http://community.livejournal.com/springkink/

  Given the following activated users exist
    | login          | password    |
    | mod1           | something   |
    | prompter1      | something   |
    | prompter2      | something   |
    | writer1        | something   |
    | writer2        | something   |
    | writer3        | something   |
    | writer4        | something   |
    And I have no tags
    And I have no prompts
    And basic tags
    And I create the fandom "Stargate Atlantis" with id 27
    And I create the fandom "Stargate SG-1" with id 28
    And a character exists with name: "John Sheppard", canonical: true
    And I am logged in as "mod1" with password "something"
  
  # set up the challenge
  
  When I go to the collections page
  When I follow "New Collection"
    And I fill in "Display Title" with "Spring Kink"
    And I fill in "Collection Name" with "springkink"
    And I select "Prompt Meme" from "challenge_type"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The Spring Kink Prompt Meme"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "prompt_meme_request_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate Atlantis, Stargate SG-1"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"
    And I check "prompt_meme_anonymous"
    And I fill in "prompt_meme_requests_num_allowed" with "1"
    And I fill in "prompt_meme_requests_num_required" with "1"
    And I check "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully created"
    
  # sign up as first prompter
  
  When I follow "Log out"
    And I am logged in as "prompter1" with password "something"
  When I go to "Spring Kink" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I press "Submit"
  Then I should see "Signup was successfully created"
    And I should see "Prompts (1)"
    
  # writer 1 replies to prompt, which is anon
  When I am logged out
    And I am logged in as "writer1" with password "something"
    And I go to "Spring Kink" collection's page
    And I follow "Prompts"
  Then I should see "Stargate Atlantis"
    And I should not see "prompter1"
  When I press "Claim"
  Then I should see "New claim made"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Response Story 1"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
  #  And I should see "Mystery work"
    
  # writer 2 replies to prompt
  
  # responses are hidden, e.g. from prompter
    
  # mod checks that word count is at least 100 and only reveals the right ones
  
  # prompter prompts for day 2
  
  # writer 1 responds for day 2
  
  # writer 3 and writer 4 respond for day 2
  
  # writer 4 responds belatedly for day 1
  
  # mod can see all that and reveal the right things
