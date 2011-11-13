@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Create a prompt meme for a large challenge like bigger memes

  Given I am logged in as "mod1"
    And I have standard challenge tags setup
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
  
  When I log out
    And I am logged in as "myname2" with password "something"
  When I sign up for Battle 12 with combination D
    And I add prompts up to 34 starting with 3
  Then I should see "Prompt was successfully added"
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
    And I press "Claim"
  Then I should see "New claim made."
  
  # 3rd user creates some more prompts
  
  When I log out
    And I am logged in as "myname3" with password "something"
  When I sign up for Battle 12 with combination D
    And I add prompts up to 24 starting with 3
    And I add prompt 25 with "Stargate SG-1"
  Then I should see "Prompt was successfully added"
  
  # filter by fandom
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "Stargate Atlantis" within ".prompt .heading"
    And I should see "Stargate SG-1" within ".prompt .heading"
  When I sort by fandom
  Then I should see "Stargate Atlantis" within ".prompt .heading"
    And I should not see "Stargate SG-1" within ".prompt .heading"
  When I sort by fandom
  Then I should see "Stargate Atlantis" within ".prompt .heading"
    And I should see "Stargate SG-1" within ".prompt .heading"
