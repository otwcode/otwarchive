@collections @challenges @wip
Feature: Prompt Meme Challenge
  In order to participate without inhibitions
  As a humble user
  I want to prompt, post and receive fills anonymously

  Scenario: Prompt anonymously and be notified of the fills without the writer knowing who I am
  Given the following activated users exist
    | login          | password    | email      |
    | mod1           | something   | mod@e.org  |
    | myname1        | something   | my1@e.org  |
    | myname2        | something   | my2@e.org  |
    And I have no tags
    And I have no prompts
    And basic tags
    And a fandom exists with name: "GhostSoup", canonical: true
    And I am logged in as "mod1" with password "something"
    And I set up a basic promptmeme "The Kissing Game"
    And I follow "Log out"
  When I am logged in as "myname1" with password "something"
    And I go to "The Kissing Game" collection's page
    # And the apostrophe stops getting in the way of highlighting in notepad++ '
    And I follow "Sign Up"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "GhostSoup"
    And I check "challenge_signup_requests_attributes_0_anonymous"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
    And I follow "Prompts (1)"
    And I press "Claim"
  Then I should see "New claim made"
    And I follow "Post To Fulfill"
  Then I should see "GhostSoup" in the "Fandoms" input
    And I should see "promptcollection" in the "work_collection_names" input
    And the "The Kissing Game (Anonymous) -  - GhostSoup" checkbox should be checked
    And the "work_recipients" field should not contain "myname1"
    And I fill in "Work Title" with "Kinky Story"
    And I fill in "Work text" with "Story written for your kinks, oh mystery reader!"
  Given all emails have been delivered
    And I press "Post without preview"
  Then I should see "Kinky Story"
  # TODO: Figure out why this isn't working
  # email the anonymous prompter that they've received a fill!
   # And 1 email should be delivered to "my1@e.org"
# TODO: when work_anonymous is implemented, test that the prompt filler can be anon too
