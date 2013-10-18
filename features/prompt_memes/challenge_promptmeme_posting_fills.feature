@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to participate without inhibitions
  As a humble user
  I want to prompt, post and receive fills anonymously

  Scenario: Prompt anonymously and be notified of the fills without the writer knowing who I am
  Given basic tags
    And a fandom exists with name: "GhostSoup", canonical: true
    And I am logged in as "mod1"
    And I set up a basic promptmeme "The Kissing Game"
    And I log out
  When I am logged in as "myname1"
    And I go to "The Kissing Game" collection's page
    # And the apostrophe stops getting in the way of highlighting in notepad++ '
    And I follow "Sign Up"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "GhostSoup"
    And I check "challenge_signup_requests_attributes_0_anonymous"
    # there are two forms in this page, can't use I submit
    And I press "Submit"
  Then I should see "Sign-up was successfully created"
  When I log out
    And I am logged in as "myname2"
    And I go to "The Kissing Game" collection's page
    And I follow "Prompts (1)"
    And I press "Claim"
  Then I should see "New claim made"
    And I follow "Fulfill"
  # Then I should see "GhostSoup" in the "Fandoms" input # feature was removed
    And I fill in "Fandoms" with "GhostSoup"
    And I should see "promptcollection" in the "work_collection_names" input
    And the "Untitled Prompt in The Kissing Game (Anonymous)" checkbox should be checked
    And the "work_recipients" field should not contain "myname1"
    And I fill in "Work Title" with "Kinky Story"
    And I fill in "content" with "Story written for your kinks, oh mystery reader!"
  Given all emails have been delivered
    And I press "Post Without Preview"
  Then I should see "Kinky Story"
  # TODO: Figure out why this isn't working
  # email the anonymous prompter that they've received a fill!
   # And 1 email should be delivered to "my1@e.org"
# TODO: when work_anonymous is implemented, test that the prompt filler can be anon too
