@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to create a collection and post to it

  Scenario: Create a collection, post a work to it

  Given the following activated user exists
    | login          | password    |
    | myname1        | something   |
    And a warning exists with name: "No Archive Warnings Apply", canonical: true
    And I am logged in as "myname1" with password "something"
  Then I should see "Hi, myname1!"
    And I should see "Log out"
  When I post the work "Test work thingy"
  Then I should see "Work was successfully posted."
  When I go to the collections page
  Then I should see "Collections in the Example Archive"
    And I should not see "My Collection Thing"
  When I follow "New Collection"
    And I fill in "Display Title" with "My Collection Thing"
    And I fill in "Collection Name" with "collection_thing"
    And I fill in "Introduction" with "Welcome to the collection"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It's a collection</dd></dl>"
    And I fill in "Rules" with "Be nice to people"
    And I press "Submit"
  Then I should see "Collection was successfully created"
  When I follow "Profile"
  Then I should see "Welcome to the collection" within "#intro"
    And I should see "What is this thing?" within "#faq"
    And I should see "It's a collection" within "#faq"
    And I should see "Be nice to people" within "#rules"
  When I go to the collections page
  Then I should see "My Collection Thing"
  When I follow "My Collection Thing"
  Then I should see "Post To Collection"
  When I post the work "collect-y work"
    And I follow "myname1"
  Then I should see "collect-y work"
  When I edit the work "collect-y work"
    And I fill in "work_collection_names" with "collection_thing"
    And I press "Preview"
    And I press "Update"
  Then I should see "collect-y work"
    And I should see "Collections: My Collection Thing"
    
  Scenario: Create a gift exchange, sign up for it

  Given the following activated users exist
    | login          | password    |
    | mod1           | something   |
    | myname1        | something   |
    | myname2        | something   |
    | myname3        | something   |
    | myname4        | something   |
    And I have no tags
    And a warning exists with name: "No Archive Warnings Apply", canonical: true
    And I create the tag "Stargate Atlantis" with id 27 and type "Fandom"
    And I create the tag "Stargate SG-1" with id 28 and type "Fandom"
    And a freeform exists with name: "Alternate Universe - Historical", canonical: true
    And a freeform exists with name: "Alternate Universe - High School", canonical: true
    And a freeform exists with name: "Something else weird", canonical: true
    And I am logged in as "mod1" with password "something"
  Then I should see "Hi, mod1!"
    And I should see "Log out"
  When I go to the collections page
  Then I should see "Collections in the Example Archive"
    And I should not see "My Gift Exchanger"
  When I follow "New Collection"
    And I fill in "Display Title" with "My Gift Exchanger"
    And I fill in "Collection Name" with "lotsofgifts"
    And I fill in "Introduction" with "Welcome to the exchange"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It's a gift exchange-y thing</dd></dl>"
    And I fill in "Rules" with "Be even nicer to people"
    And I select "Gift Exchange" from "challenge_type"
    And I check "Is this collection currently unrevealed?"
    And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The My Gift Exchanger Gift Exchange"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "Request Instructions" with "Please request easy things"
    And I fill in "Offer Instructions" with "Please offer lots of stuff"
    And I fill in "gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate SG-1, Stargate Atlantis"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_freeform_num_allowed" with "2"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_freeform_num_allowed" with "2"
    And I check "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully created"
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
  When I go to the collections page
  Then I should see "My Gift Exchanger"
  When I follow "My Gift Exchanger"
  Then I should see "Sign Up"
  When I follow "Profile"
  Then I should see "Welcome to the exchange" within "#intro"
    And I should see "What is this thing?" within "#faq"
    And I should see "It's a gift exchange-y thing" within "#faq"
    And I should see "Be even nicer to people" within "#rules"
  When I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_offers_attributes_0_fandom_28"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - Historical"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"
    And I press "Submit"
  Then I should see "Signup was successfully created"
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
