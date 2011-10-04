@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it

  Scenario: Create a prompt meme for a challenge like http://community.livejournal.com/springkink/

    # And I create the fandom "Stargate Atlantis" with id 37
    # And I create the fandom "Stargate SG-1" with id 38
    Given the following activated users exist
      | login          | password    |
      | mod1           | something   |
      | prompter1      | something   |
      | prompter2      | something   |
      | writer1        | something   |
      | writer2        | something   |
      | writer3        | something   |
      | writer4        | something   |
      And I am logged in as "mod1" with password "something"
      And I have standard challenge tags set up

    # set up the challenge

    When I go to the collections page
    When I set up an anon promptmeme "Spring Kink"
      And I follow "Challenge Settings"
    When I fill in "General Signup Instructions" with "Here are some general tips"
      And I fill in "Tag Sets To Use:" with "Standard Challenge Tags"
      And I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"
      And I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"
      And I check "prompt_meme_anonymous"
      And I fill in "prompt_meme_requests_num_allowed" with "1"
      And I fill in "prompt_meme_requests_num_required" with "1"
      And I press "Update"
    Then I should see "Challenge was successfully updated"

  # sign up as first prompter
  
  When I follow "Log out"
    And I am logged in as "prompter1" with password "something"
  When I go to "Spring Kink" collection's page
    And I follow "Sign Up"
    And I check "Stargate Atlantis"
    And I submit
  Then I should see "Signup was successfully created"
    And I should see "Prompts (1)"
    
  # writer 1 replies to prompt, which is anon
  When I am logged out
    And I am logged in as "writer1" with password "something"
    And I go to "Spring Kink" collection's page
    And I follow "Prompts ("
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
    And I should see "This work is part of an ongoing challenge and will be revealed soon!"
    
  # writer 2 replies to prompt
  When I am logged out
    And I am logged in as "writer2" with password "something"
    And I go to "Spring Kink" collection's page
    And I follow "Prompts ("
    
    # TODO: Figure out if this is the sensible workflow, or if there should be a way to make the prompt stay there for challenges like this.
    And I follow "Show Filled"
    And I press "Claim"
  Then I should see "New claim made"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Response Story 2"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis, and it is several more words long"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
  
  # responses are hidden, e.g. from prompter
  When I am logged out
    And I am logged in as "prompter1" with password "something"
    And I go to "Spring Kink" collection's page
    And I follow "Works"
  Then I should not see "writer1"
    And I should not see "Response Story"
    # And I should see "Mystery Work"
    
  # mod checks that word count is at least 100 and only reveals the right ones
  When I am logged out
    And I am logged in as "mod1" with password "something"
  
  # prompter prompts for day 2
  
  # writer 1 responds for day 2
  
  # writer 3 and writer 4 respond for day 2
  
  # writer 4 responds belatedly for day 1
  
  # mod can see all that and reveal the right things
