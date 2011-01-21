@collections
Feature: Gift Exchange Challenge
  In order to have more fics for my fandom
  As a humble user
  I want to run a gift exchange

  Scenario: Create a gift exchange, sign up for it

  Given the following activated users exist
    | login          | password    |
    | mod1           | something   |
    | myname1        | something   |
    | myname2        | something   |
    | myname3        | something   |
    | myname4        | something   |
    And I have no tags
    And I create the fandom "Stargate Atlantis" with id 27
    And I create the fandom "Stargate SG-1" with id 28
    And a freeform exists with name: "Alternate Universe - Historical", canonical: true
    And a freeform exists with name: "Alternate Universe - High School", canonical: true
    And a freeform exists with name: "Something else weird", canonical: true
    And I am logged in as "mod1" with password "something"
  Then I should see "Hi, mod1!"
    And I should see "Log out"
    
  # set up the gift exchange
  
  When I go to mod1's preferences page
  #'
  Then I should see "Your time zone"
    And "TODO: checking an option is selected" is fixed
    # And I should find "(GMT-05:00) Eastern Time (US & Canada)" selected within "preference_time_zone"
  When I select "(GMT-09:00) Alaska" from "preference_time_zone"
    And I press "Update"
  Then I should see "Your preferences were successfully updated."
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "My Gift Exchanger"
  When I follow "New Collection"
    And I fill in "Display Title" with "My Gift Exchanger"
    And I fill in "Collection Name" with "lotsofgifts"
    And I fill in "Introduction" with "Welcome to the exchange"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It is a gift exchange-y thing</dd></dl>"
    And I fill in "Rules" with "Be even nicer to people"
    And I select "Gift Exchange" from "challenge_type"
    And I check "Is this collection currently unrevealed?"
    And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The My Gift Exchanger Gift Exchange"
    And "ditto" is fixed
    # And I should find "(GMT-09:00) Alaska" selected within "gift_exchange_time_zone"
    And I should see "(GMT-09:00) Alaska" within "#main"
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
    And I check "Signup open?"
    And I press "Submit"
    And "issue 1859" is fixed
  # Then I should see "If signup is open, signup closed date can't be in the past"
  # When I select "2012" from "gift_exchange_signups_open_at_1i"
  #   And I select "2012" from "gift_exchange_signups_close_at_1i"
  #   And I press "Submit"
  # Then I should see "If signup is open, signup opening date can't be in the future"
  # When I select "2011" from "gift_exchange_signups_open_at_1i"
  #   And I press "Submit"
  Then I should see "Challenge was successfully created"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN" within ".collection.meta"
    And I should see "Signup closes:"
  ### TODO fix timezone dependency before next spring!
    And I should see "EST ("
    And I should see "AKST)"
  When I follow "Challenge Settings"
    And I select "(GMT-09:00) Alaska" from "gift_exchange_time_zone"
    # TODO: Raise an issue to rename this button to something more descriptive
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN"
  ### TODO fix timezone dependency before next spring!
    And I should not see "EST" within "#main"
    And I should see "AKST" within "#main"
    
  # sign up
  
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
  When I go to the collections page
  Then I should see "My Gift Exchanger"
  When I follow "My Gift Exchanger"
  Then I should see "Sign Up"
  When I follow "Profile"
  Then I should see "Welcome to the exchange" within "#intro"
    And I should see "Signup: CURRENTLY OPEN"
    And I should see "Signup closes:"
    And I should see "2011" within ".collection.meta"
    And I should see "What is this thing?" within "#faq"
    And I should see "It is a gift exchange-y thing" within "#faq"
    And I should see "Be even nicer to people" within "#rules"
  When I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_0_fandom_28"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - Historical"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # someone else sign up
  
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
    And I follow "My Gift Exchanger"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School, Something else weird"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # third person sign up
  
  When I follow "Log out"
    And I am logged in as "myname3" with password "something"
  When I go to the collections page
    And I follow "My Gift Exchanger"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
    And I check "challenge_signup_offers_attributes_0_fandom_28"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # check you can see signups in the dashboard
  
  When I follow "myname3"
  Then I should see "My Signups (1)"
  When I follow "My Signups (1)"
  Then I should see "My Gift Exchanger"
  
  # fourth person sign up
  
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to the collections page
    And I follow "My Gift Exchanger"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I go to the collections page
    And I follow "My Gift Exchanger"
  Then I should not see "Signups"
  
  # mod view signups
  
  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
    And I go to the collections page
    And I follow "My Gift Exchanger"
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
  Then I should see "Matching for My Gift Exchanger"
    And I should see "Generate Potential Matches"
    And I should see "You can shuffle these assignments around as much as you want."
  When I follow "Generate Potential Matches"
  Then I should see "Beginning generation of potential matches. This may take some time, especially if your challenge is large."
  Given the system processes jobs
    And I wait 3 seconds
  When I reload the page
  Then I should see "Main Assignments"
  When I follow "Send Assignments"
  Then I should see "Assignments are now being sent out"
