@collections
Feature: Collection
  I want to test Yuletide, because it has several specific settings that are different from an ordinary gift exchange

  Scenario: Create a Yuletide gift exchange, sign up for it, run matching, post, fulfil pinch hits

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
    And I create the fandom "Tiny fandom" with id 29
    And I create the fandom "Care Bears" with id 30
    And I create the fandom "Yuletide Hippos RPF" with id 31
    And a character exists with name: "John Sheppard", canonical: true
    And a character exists with name: "Teyla Emmagan", canonical: true
    And a character exists with name: "Obscure person", canonical: true
    And I am logged in as "mod1" with password "something"
  Then I should see "Hi, mod1!"
    And I should see "Log out"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Yuletide"
  When I follow "New Collection"
    And I fill in "Display Title" with "Yuletide"
    And I fill in "Collection Name" with "yule2011"
    And I fill in "Introduction" with "Welcome to the exchange"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It's a gift exchange-y thing</dd></dl>"
    And I fill in "Rules" with "Be even nicer to people"
    And I select "Gift Exchange" from "challenge_type"
    And I check "Is this collection currently unrevealed?"
    And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The Yuletide Gift Exchange"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "Request Instructions" with "Please request easy things"
    And I fill in "Offer Instructions" with "Please offer lots of stuff"
    And I check "gift_exchange_request_restriction_attributes_url_allowed"
    And I uncheck "gift_exchange_offer_restriction_attributes_description_allowed"
    And I fill in "gift_exchange_requests_num_required" with "3"
    And I fill in "gift_exchange_requests_num_allowed" with "4"
    And I fill in "gift_exchange_offers_num_required" with "3"
    And I fill in "gift_exchange_offers_num_allowed" with "4"
    And I fill in "gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate SG-1, Stargate Atlantis, Tiny fandom, Care Bears, Yuletide Hippos RPF"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_character_num_allowed" with "4"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_character_num_allowed" with "4"
    And I check "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully created"
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
  When I go to the collections page
  Then I should see "Yuletide"
  When I follow "Yuletide"
  Then I should see "Sign Up"
  When I follow "Profile"
  Then I should see "About Yuletide (yule2011)"
    And I should see "Signup:" within ".collection.meta"
    And I should see "CURRENTLY OPEN" within ".collection.meta"
    And I should see "Signup closes:" within ".collection.meta"
    And I should see "Assignments due:" within ".collection.meta"
    And I should see "Works revealed:" within ".collection.meta"
    And I should see "Authors revealed:" within ".collection.meta"
    And I should see "Signed up:" within ".collection.meta"
    And I should see "0" within ".collection.meta"
    And I should see "Welcome to the exchange" within "#intro"
    And I should see "What is this thing?" within "#faq"
    And I should see "It's a gift exchange-y thing" within "#faq"
    And I should see "Be even nicer to people" within "#rules"
  When I follow "Sign Up"
  Then I should see "Requests (3 - 4)"
    And I should see "Offers (3 - 4)"
  # users need to see a list of possible fandoms, either here or elsewhere, when signing up
    And I should see "Stargate Atlantis"
    And I should see "Stargate SG-1"
    And I should see "Tiny fandom"
    And I should see "Care Bears"
    And I should see "Yuletide Hippos RPF"
  When I check "challenge_signup_requests_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard"
    And I check "challenge_signup_offers_attributes_0_fandom_30"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Obscure person"
    And I fill in "Description" with "This is my wordy request"
    And issue "1825" is fixed
    #  And I fill in "Prompt URL" with "http://user.dreamwidth.org/123.html"
    And I fill in "Url" with "http://user.dreamwidth.org/123.html"
    And I press "Submit"
  Then I should see "We couldn't save this challenge signup, sorry!"
  # TODO: We should probably make these error message more friendly
    And I should see "Request must have exactly 1 fandom tags. You currently have none."
    And I should see "Offer must have exactly 1 fandom tags. You currently have none."
  When I check "challenge_signup_requests_attributes_1_fandom_29"
    And I fill in "challenge_signup_requests_attributes_1_tag_set_attributes_character_tagnames" with "Teyla Emmagan"
    And I check "challenge_signup_requests_attributes_2_fandom_28"
    And I check "challenge_signup_offers_attributes_1_fandom_31"
    And I check "challenge_signup_offers_attributes_2_fandom_28"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # another person signs up
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Profile"
  # before signing up, you can check who else has already signed up
  Then I should see "Signed up:" within ".collection.meta"
    And I should see "1" within ".collection.meta"
  When I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
    And I check "challenge_signup_requests_attributes_1_fandom_29"
    And I check "challenge_signup_requests_attributes_2_fandom_31"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_1_fandom_31"
    And I check "challenge_signup_offers_attributes_2_fandom_31"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "Obscure person"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard"
    # And the indexes thing is fixed
    # And I follow "Add another request? (Up to 4 allowed.)"
    # And I check "challenge_signup_requests_attributes_3_fandom_30"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # and a third person signs up
  When I follow "Log out"
    And I am logged in as "myname3" with password "something"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
    And I check "challenge_signup_requests_attributes_1_fandom_29"
    And I check "challenge_signup_requests_attributes_2_fandom_31"
    And I check "challenge_signup_offers_attributes_0_fandom_28"
    And I check "challenge_signup_offers_attributes_1_fandom_31"
    And I check "challenge_signup_offers_attributes_2_fandom_30"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "Any"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Teyla Emmagan"
    And I press "Submit"
  Then I should see "We couldn't save this challenge signup, sorry!"
    And I should see "The following character tags aren't canonical and can't be used: Any"
  When I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with ""
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # fourth person signs up
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_29"
    And I check "challenge_signup_requests_attributes_2_fandom_31"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_1_fandom_31"
    And I check "challenge_signup_offers_attributes_2_fandom_31"
    And I fill in "challenge_signup_requests_attributes_2_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Obscure person"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  # ordinary users can't see signups
  When I go to the collections page
    And I follow "Yuletide"
  Then I should not see "Signups"
  
  # mod can view signups
  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
    And I go to the collections page
    And I follow "Yuletide"
    And I follow "Signups"
  Then I should see "myname4" within "#main"
    And I should see "myname3" within "#main"
    And I should see "myname2" within "#main"
    And I should see "myname1" within "#main"
    And I should see "John Sheppard"
    And I should see "Obscure person"
    And I should see "http://user.dreamwidth.org/123.html"
  When I follow "Hide URLs"
  Then I should not see "http://user.dreamwidth.org/123.html"
  
  # mod runs matching
  When I follow "Matching"
  Then I should see "You cannot generate matches while signup is still open."
    And I should not see "Generate Potential Matches"
  When I follow "Challenge Settings"
    And I uncheck "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Matching"
  Then I should see "Matching for Yuletide"
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
    And I should see "No defaulted assignments!"
    And I should see "Not yet posted"
  When I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"
