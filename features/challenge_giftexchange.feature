@collections
Feature: Gift Exchange Challenge
  In order to have more fics for my fandom
  As a humble user
  I want to run a gift exchange

  Scenario: Create a collection to house a gift exchange
  Given I have standard challenge tags setup
    And I am logged in as "mod1"
  When I set up the collection "My Gift Exchange" 
    And I select "Gift Exchange" from "challenge_type"
    # And I check "Is this collection currently unrevealed?"
    # And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The My Gift Exchange Gift Exchange"
    And I should see "Offer Settings"
    And I should see "Request Settings"
    And I should see "If you plan to use automated matching"
    And I should see "Allow Any"

  Scenario: Enter settings for a gift exchange
  Given I am logged in as "mod1"
    And I have set up the gift exchange "My Gift Exchange"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "Request Instructions" with "Please request easy things"
    And I fill in "Offer Instructions" with "Please offer lots of stuff"
    And I select "2011" from "gift_exchange_signups_open_at_1i"
    And I select "2011" from "gift_exchange_signups_close_at_1i"
    And I select "(GMT-05:00) Eastern Time (US & Canada)" from "gift_exchange_time_zone"
    And I fill in "gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate SG-1, Stargate Atlantis"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_freeform_num_allowed" with "2"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_freeform_num_allowed" with "2"
    And I select "1" from "gift_exchange_potential_match_settings_attributes_num_required_fandoms"
    And I press "Submit"
  Then I should see "Challenge was successfully created"
  When I follow "Profile"
  Then I should see "2011" within ".collection.meta"

  Scenario: Open signup in a gift exchange
  Given I am logged in as "mod1"
    And I have created the gift exchange "My Gift Exchange"
    And I am on "My Gift Exchange" gift exchange edit page
  When I check "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN" within ".collection.meta"
    And I should see "Signup closes:"

  Scenario: Change timezone for a gift exchange
  Given I am logged in as "mod1"
    And I have created the gift exchange "My Gift Exchange"
    And I am on "My Gift Exchange" gift exchange edit page
  When I select "(GMT-09:00) Alaska" from "gift_exchange_time_zone"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Profile"
  Then I should find "Alaska"

  Scenario: Sign up for a gift exchange
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
  When I am logged in as "myname1"
    And I go to the collections page
  Then I should see "Awesome Gift Exchange"
  When I follow "Awesome Gift Exchange"
  Then I should see "Sign Up"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN"
    And I should see "Signup closes:"
  When I sign up for "Awesome Gift Exchange" with combination A
  Then I should see "Signup was successfully created"

  # someone else sign up

  When I follow "Log out"
    And I am logged in as "myname2"
  When I sign up for "Awesome Gift Exchange" with combination B
  Then I should see "Signup was successfully created"

  # third person sign up

  When I follow "Log out"
    And I am logged in as "myname3"
  When I sign up for "Awesome Gift Exchange" with combination C
  Then I should see "Signup was successfully created"

  # check you can see signups in the dashboard

  When I follow "myname3"
  Then I should see "My Signups (1)"
  When I follow "My Signups (1)"
  Then I should see "Awesome Gift Exchange"

  # fourth person sign up

  When I follow "Log out"
    And I am logged in as "myname4"
  When I go to the collections page
    And I follow "Awesome Gift Exchange"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I go to the collections page
    And I follow "Awesome Gift Exchange"
  Then I should not see "Signups"

  # mod view signups

  When I follow "Log out"
    And I am logged in as "mod1"
    And I go to the collections page
    And I follow "Awesome Gift Exchange"
    And I follow "Signups"
  Then I should see "myname4" within "#main"
    And I should see "myname3" within "#main"
    And I should see "myname2" within "#main"
    And I should see "myname1" within "#main"
    And I should see "Something else weird"
    And I should see "Alternate Universe - Historical"
  When I follow "Matching"
  Then I should see "You cannot generate matches while signup is still open."
    And I should not see "Generate Potential Matches"
  When I follow "Challenge Settings"
    And I uncheck "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Matching"
  Then I should see "Matching for Awesome Gift Exchange"
    And I should see "Generate Potential Matches"
    And I should see "You can shuffle these assignments around as much as you want."
  When I follow "Generate Potential Matches"
  Then I should see "Beginning generation of potential matches. This may take some time, especially if your challenge is large."
  Given the system processes jobs
    And I wait 3 seconds
  When I reload the page
  Then I should see "Main Assignments"
  When all emails have been delivered
    And I follow "Send Assignments"
  Then I should see "Assignments are now being sent out"
  Given the system processes jobs
    And I wait 3 seconds
  When I reload the page
  Then I should not see "Assignments are now being sent out"
  # 4 users and the mod should get emails :)
    And 1 email should be delivered to "mod1"
    And the email should contain "You have received a message about your collection"
  When I click the first link in the email
  Then I should see "Sorry, we couldn't find the collection you were looking for"
    And 1 email should be delivered to "myname1"
    And 1 email should be delivered to "myname2"
    And 1 email should be delivered to "myname3"
    And 1 email should be delivered to "myname4"
    And the email should link to "Awesome Gift Exchange" collection's url
      And the email should link to myname1's user url
      And the email should link to the works tagged "Stargate Atlantis"
