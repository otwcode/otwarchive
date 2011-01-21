@collections
Feature: Collection
  I want to test Yuletide, because it has several specific settings that are different from an ordinary gift exchange

  # uncomment this and the other 'javascript' lines below when testing on local
  # in order to test javascript-based features
  #@javascript
  Scenario: Create a Yuletide gift exchange, sign up for it, run matching, post, fulfil pinch hits

  Given the following activated users exist
    | login          | password    |
    | mod1           | something   |
    | myname1        | something   |
    | myname2        | something   |
    | myname3        | something   |
    | myname4        | something   |
    | pinchhitter    | password    |
    And I have no tags
    And I have no challenge assignments
    And I create the fandom "Stargate Atlantis" with id 27
    And I create the fandom "Starsky & Hutch" with id 28
    And I create the fandom "Tiny fandom" with id 29
    And I create the fandom "Care Bears" with id 30
    And I create the fandom "Yuletide Hippos RPF" with id 31
    And basic tags
    And a character exists with name: "John Sheppard", canonical: true
    And I add the fandom "Stargate Atlantis" to the character "John Sheppard"
    And I add the fandom "Starsky & Hutch" to the character "John Sheppard"
    And I add the fandom "Tiny fandom" to the character "John Sheppard"
    And a character exists with name: "Teyla Emmagan", canonical: true
    And I add the fandom "Stargate Atlantis" to the character "Teyla Emmagan"
    And I add the fandom "Starsky & Hutch" to the character "Teyla Emmagan"
    And a character exists with name: "Foo The Wonder Goat", canonical: true
    And I add the fandom "Tiny fandom" to the character "Foo The Wonder Goat"
    And I add the fandom "Starsky & Hutch" to the character "Foo The Wonder Goat"
    And a character exists with name: "Obscure person", canonical: true
    And I add the fandom "Tiny fandom" to the character "Obscure person"
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
    # for testing convenience while still exercising the options, we are going with
    # 2-3 requests, 2-3 offers
    # url allowed in request
    # description not allowed in offer
    # 1 fandom required in offer and request
    # 0-2 characters allowed in request
    # 2-3 characters required in offer
    # unique fandoms required in offers and requests
    # "any" option available in offers
    # match on 1 fandom and 1 character
    And I check "gift_exchange_request_restriction_attributes_url_allowed"
    And I uncheck "gift_exchange_offer_restriction_attributes_description_allowed"
    And I fill in "gift_exchange_requests_num_required" with "2"
    And I fill in "gift_exchange_requests_num_allowed" with "3"
    And I fill in "gift_exchange_offers_num_required" with "2"
    And I fill in "gift_exchange_offers_num_allowed" with "3"
    And I fill in "gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Starsky & Hutch, Stargate Atlantis, Tiny fandom, Care Bears, Yuletide Hippos RPF"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_request_restriction_attributes_fandom_num_allowed" with "1"
    And I check "gift_exchange_request_restriction_attributes_require_unique_fandom"
    And I fill in "gift_exchange_request_restriction_attributes_character_num_allowed" with "2"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_required" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "gift_exchange_offer_restriction_attributes_character_num_required" with "2"
    And I fill in "gift_exchange_offer_restriction_attributes_character_num_allowed" with "3"
    And I check "gift_exchange_offer_restriction_attributes_require_unique_fandom"
    And I check "gift_exchange_offer_restriction_attributes_allow_any_character"
    And I select "1" from "gift_exchange_potential_match_settings_attributes_num_required_fandoms"
    And I select "1" from "gift_exchange_potential_match_settings_attributes_num_required_characters"
    And I check "gift_exchange_offer_restriction_attributes_character_restrict_to_fandom"
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
  Then I should see "General Information"
    And I should see "Here are some general tips"
    And I should see "Requests (2 - 3)"
    And I should see "Please request easy things"
    And I should see "Request 1"
    And I should see "Fandom (1):"
    And I should see "Show all 5 options"
    And I should see "Care Bears"
    And I should see "Stargate Atlantis"
    And I should see "Starsky & Hutch"
    And I should see "Tiny fandom"
    And I should see "Yuletide Hippos RPF"
    And I should see "Characters (0 - 2):"
    And I should see "Prompt URL:"
    And I should see "Description:"
    And I should see "Request 2"
    And I should not see "Request 3"
    And I should see "Add another request? (Up to 3 allowed.)"
    And I should see "Offers (2 - 3)"
    And I should see "Please offer lots of stuff"
    And I should see "Offer 1"
    And I should see "Characters (2 - 3)"
    And I should see "Any?"
    And I should see "Offer 2"
    And I should not see "Offer 3"
    And I should see "Add another offer? (Up to 3 allowed.)"
  # we fill in 1 request with 1 fandom, 1 character; 1 offer with 1 fandom and 1 character
  When I check "challenge_signup_requests_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard"
    And I fill in "Prompt URL" with "http://user.dreamwidth.org/123.html"
    And I fill in "Description" with "This is my wordy request"
    And I check "challenge_signup_offers_attributes_0_fandom_30"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Obscure person"
    And I press "Submit"
  Then I should see "We couldn't save this ChallengeSignup, sorry!"
  # TODO: We should probably make these error message more friendly
    # errors for the empty request
    And I should see "Request must have exactly 1 fandom tags. You currently have none."
    # errors for the not-quite-filled offer
    And I should see "Offer must have between 2 and 3 character tags. You currently have (1) -- Obscure person"
    And I should see "Your Offer has some character tags that are not in the selected fandom(s)"
    # errors for the empty offer
    And I should see "Offer must have exactly 1 fandom tags. You currently have none."
    And I should see "Offer must have between 2 and 3 character tags. You currently have none."
  # Over-fill the remaining missing fields and duplicate fandoms
  When I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan, Obscure person"
    And I check "challenge_signup_requests_attributes_1_fandom_29"
    And I check "challenge_signup_requests_attributes_1_fandom_28"
    And I fill in "challenge_signup_requests_attributes_1_tag_set_attributes_character_tagnames" with "Teyla Emmagan"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Obscure person, John Sheppard"
    And I check "challenge_signup_offers_attributes_1_fandom_30"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Obscure person, John Sheppard, Teyla Emmagan, Foo The Wonder Goat"
    And I press "Submit"
  Then I should see "We couldn't save this ChallengeSignup, sorry!"
    And I should see "Request must have between 0 and 2 character tags. You currently have (3) -- John Sheppard, Teyla Emmagan, Obscure person."
    And I should see "Your Request has some character tags that are not in the selected fandom(s), Stargate Atlantis: Obscure person"
    And I should see "Request must have exactly 1 fandom tags. You currently have (2) -- Starsky & Hutch, Tiny fandom."
    And I should see "Your Offer has some character tags that are not in the selected fandom(s), Care Bears: Obscure person, John Sheppard"
    And I should see "Offer must have between 2 and 3 character tags. You currently have (4) -- Obscure person, John Sheppard, Teyla Emmagan, Foo The Wonder Goat."
    And I should see "Your Offer has some character tags that are not in the selected fandom(s), Care Bears: Obscure person, John Sheppard, Teyla Emmagan, Foo The Wonder Goat"
    And I should see "You have submitted more than one offer with the same fandom tags. This challenge requires them all to be unique."
  # now fill in correctly
  When I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan"
    And I uncheck "challenge_signup_requests_attributes_1_fandom_28"
    And I fill in "challenge_signup_requests_attributes_1_tag_set_attributes_character_tagnames" with "Obscure person"
    And I uncheck "challenge_signup_offers_attributes_0_fandom_30"
    And I check "challenge_signup_offers_attributes_0_fandom_29"
    And I uncheck "challenge_signup_offers_attributes_1_fandom_30"
    And I check "challenge_signup_offers_attributes_1_fandom_28"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan, Foo The Wonder Goat"
    And I press "Submit"
  Then I should see "Signup was successfully created"
    And I should see "Signup for myname1"
    And I should see "Request 1"
    And I should see "This is my wordy request"
    And I should see "Request 2"
    And I should not see "Request 3"
    And I should see "Offer 1"
    And I should see "Offer 2"
    And I should not see "Offer 3"
    And I should see "Edit"
    And I should see "Delete"

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
  When I check "challenge_signup_requests_attributes_0_fandom_28"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard"
    And I check "challenge_signup_requests_attributes_1_fandom_29"
    And I check "challenge_signup_offers_attributes_0_fandom_27"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan"
    And I check "challenge_signup_offers_attributes_1_fandom_31"
    And I check "challenge_signup_offers_attributes_1_any_character"
    # TRICKY note here! the index value for the javascript-added request 3 is actually 3; this is
    # a workaround because otherwise it would display a duplicate number
    # These three commented out so it can run on the command-line
    #And I follow "Add another request? (Up to 3 allowed.)"
    #Then I should see "Request 3"
    #And I check "challenge_signup_requests_attributes_3_fandom_30"
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
    And I check "challenge_signup_offers_attributes_0_fandom_28"
    And I check "challenge_signup_offers_attributes_1_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_character_tagnames" with "Any"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Teyla Emmagan, John Sheppard"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Teyla Emmagan, John Sheppard"
    And I press "Submit"
  Then I should see "We couldn't save this ChallengeSignup, sorry!"
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
    And I check "challenge_signup_requests_attributes_1_fandom_28"
    And I fill in "challenge_signup_requests_attributes_1_tag_set_attributes_character_tagnames" with "John Sheppard, Teyla Emmagan"
    And I check "challenge_signup_offers_attributes_0_fandom_29"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Obscure person, John Sheppard"
    And I check "challenge_signup_offers_attributes_1_fandom_28"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Foo The Wonder Goat, John Sheppard"
    And I press "Submit"
  Then I should see "Signup was successfully created"

  # ordinary users can't see signups until 5 people have signed up
  When I go to the collections page
    And I follow "Yuletide"
  Then I should not see "Signups"
    And I should see "Signup Summary"
  When I follow "Signup Summary"
  Then I should see "Summary does not appear until at least 5 signups have been made!"
    And I should not see "Stargate Atlantis"

  # fifth person signs up
  When I follow "Log out"
    And I am logged in as "myname5" with password "something"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_28"
    And I check "challenge_signup_offers_attributes_0_fandom_29"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Foo The Wonder Goat, Obscure Person"
    And I check "challenge_signup_offers_attributes_1_fandom_27"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Teyla Emmagan, John Sheppard"
    And I press "Submit"
  Then I should see "Signup was successfully created"

  # ordinary users can't see signups but can see summary
  When I go to the collections page
    And I follow "Yuletide"
  Then I should not see "Signups"
    And I should see "Signup Summary"
  When I follow "Signup Summary"
  Then I should see "Signup Summary for Yuletide"
    And I should see "Requested Fandoms"
    And I should see "Starsky & Hutch [4, 3]"
    And I should see "Stargate Atlantis [3, 3]"
    And I should see "Tiny fandom [3, 3]"
    
  # signup summary changes when another person signs up
  When I follow "Log out"
    And I am logged in as "myname6" with password "something"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_28"
    And I check "challenge_signup_offers_attributes_0_fandom_29"
    And I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_character_tagnames" with "Foo The Wonder Goat, Obscure Person"
    And I check "challenge_signup_offers_attributes_1_fandom_27"
    And I fill in "challenge_signup_offers_attributes_1_tag_set_attributes_character_tagnames" with "Teyla Emmagan, John Sheppard"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I go to the collections page
    And I follow "Yuletide"
    And I follow "Signup Summary"
  Then I should see "Signup Summary for Yuletide"
    And I should see "Requested Fandoms"
    And I should see "Starsky & Hutch [5, 3]"
    And I should see "Stargate Atlantis [4, 4]"
    And I should see "Tiny fandom [3, 4]"

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
    And I should see "myname5" within "#main"
    And I should see "myname6" within "#main"
    And I should see "John Sheppard"
    And I should see "Obscure person"
    And I should not see "http://user.dreamwidth.org/123.html"
  When I follow "Show URLs"
  Then I should see "http://user.dreamwidth.org/123.html"

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
    And I should not see "Missing Recipients"
    And I should not see "Missing Givers"
    And I should see "Regenerate Assignments"
    And I should see "Regenerate Potential Matches"
    And I should see "Send Assignments"

  # mod sends assignments out
  When all emails have been delivered
    And I follow "Send Assignments"
  Then I should see "Assignments are now being sent out"
    And I should see "No defaulted assignments!"
    And I should see "Not yet posted"
    And I should not see "No recipient"
    And I should see "Purge Assignments"
    And I should see "Default All Unposted"
    And I should see "Show Assigned Pinch Hits"
    Given the system processes jobs
      And I wait 3 seconds
    When I reload the page
    Then I should not see "Assignments are now being sent out"
      # 6 users and the mod should get emails :)
      And 7 emails should be delivered

  # first user starts posting
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I go to myname1's user page
    And all emails have been delivered
    #' stop annoying syntax highlighting after apostrophe
  Then I should see "My Assignments (1)"
  When I follow "My Assignments"
  Then I should see "Writing For" within "table"
    And I should see "myname" within "table"
    And I should see "Yuletide" within "table"
    And I should see "Post To Fulfill"
  When I follow "Post To Fulfill"
  Then I should see "Post New Work"
  When I fill in "Work Title" with "Fulfilling Story"
    And I fill in "Fandoms" with "Stargate Atlantis"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I select "myname1" from "work_author_attributes_ids_"
    And I fill in "content" with "This is an exciting story about Atlantis"
  When I press "Preview"
  Then I should see "Preview Work"
    And 0 emails should be delivered

  # someone looks while it's still a draft
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
    And I go to myname2's user page
    #' stop annoying syntax highlighting after apostrophe
  Then I should see "My Gifts (0)"
    And I should not see "My Gifts (1)"
  When I follow "My Gifts"
  Then I should not see "Stargate Atlantis"
    And I should not see "myname" within "#main ul.gift"
  When I go to the collections page
    And I follow "Yuletide"
  Then I should see "Works (0)"
    And I should see "Fandoms (0)"
  When I follow "Works (0)"
  Then I should not see "Stargate"
    And I should not see "myname" within "#main"
  When I follow "Fandoms (0)"
  Then I should not see "Stargate"
    And I should not see "myname" within "#main"
  When I follow "Random Items"
  Then I should not see "Stargate"
    And I should not see "myname" within "#main"

  # first user posts the work
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I go to myname1's user page
    #' stop annoying syntax highlighting after apostrophe
    And I follow "My Drafts"
  Then I should see "Fulfilling Story"
  When I follow "Edit"
    And I fill in "Fandoms" with "Stargate Atlantis"
    And I press "Preview"
  Then I should see "Preview"
    And I should see "Fulfilling Story"
    And I should see "myname" within "#main"
    And I should see "Anonymous"
    And 0 emails should be delivered
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
    # notification is still not sent, because it's unrevealed
    And 0 emails should be delivered

  # someone tries to view it
  When I follow "Log out"
    And I go to myname1's user page
    #' stop annoying syntax highlighting after apostrophe
  Then I should see "Mystery Work"
    And I should see "Yuletide"
    And I should not see "Fulfilling Story"
    And I should not see "Stargate Atlantis"
  When I follow "Works (1)"
  Then I should not see "Stargate Atlantis"

  # user edits it to undo fulfilling the assignment
  # When I am logged in as "myname1" with password "something"
  #   And I go to myname1's user page
  #   #' stop highlighting
  # Then I should see "Fulfilling Story"
  # When I follow "Edit"
  # When I uncheck "Yuletide (myname3)"
  #   And I fill in "work_collection_names" with ""
  #   And I fill in "work_recipients" with ""
  # When I press "Preview"
  # Then show me the page
  # Then I should see "Work was successfully updated"

  # post works for all the assignments
  When I am logged in as "myname2" with password "something"
    And I go to myname2's user page
    #' stop annoying syntax highlighting after apostrophe
    And I follow "My Assignments"
  Then I should see "Writing For" within "table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story"
    And I fill in "Fandoms" with "Stargate Atlantis"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Successfully logged out"
  
  When I am logged in as "myname3" with password "something"
    And I go to myname3's user page
    #' stop annoying syntax highlighting after apostrophe
    And I follow "My Assignments"
  Then I should see "Writing For" within "table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Some Other Story"
    And I fill in "Fandoms" with "Tiny Fandom"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about a tiny little group of people"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Successfully logged out"
  
  When I am logged in as "myname4" with password "something"
    And I go to myname4's user page
    #' stop annoying syntax highlighting after apostrophe
    And I follow "My Assignments"
  Then I should see "Writing For" within "table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story"
    And I fill in "Fandoms" with "Starsky & Hutch, Tiny Fandom"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "I am not good at inventing stories"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Successfully logged out"
  
  # user leaves it as a draft
  When I am logged in as "myname5" with password "something"
    And I go to myname5's user page
    #' stop annoying syntax highlighting after apostrophe
    And I follow "My Assignments"
  Then I should see "Writing For" within "table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story"
    And I fill in "Fandoms" with "Starsky & Hutch"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "Coding late at night is bad for the brain."
  When I press "Preview"
  Then I should not see "Work was successfully posted"
    And I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
  
  # TODO: Mod checks for unfulfilled assignments, and gets pinch-hitters to do them.
  When I am logged in as "mod1" with password "something"
    And I go to the collections page
    And I follow "Yuletide"
    And I follow "Assignments"
  Then I should see "No defaulted assignments!"
    And I should see "Not yet posted"
    # myname5 has not yet posted as it is still a draft
    And "issue 2116" is fixed
    # And I should see the text with tags "Not yet posted </td><td></td></tr><tr><td>myname6"
    # myname6 has not yet posted
    # TODO: Find a way to check this, or add a label to the line so we can check
    # other people have posted
    And I should see "Gift posted on"
  When I follow "Default All Unposted"
  Then I should not see "No defaulted assignments!"
    And I should not see "Not yet posted"
    And I should see "All unfulfilled assignments marked as defaulting."
  When I fill in "challenge_assignment_pinch_hitter_byline" with "pinchhitter"
    # TODO: Figure out why this doesn't work
    # And I press "Assign"
  # Then show me the page
  
  # pinch hitter writes story
  When I follow "Log out"
    And I am logged in as "pinchhitter" with password "something"
    And I go to pinchhitter's user page
    And I follow "My Assignments"
    # TODO: fix line just above
  # Then I should see "Writing For" within "table"
  # When I follow "Post To Fulfill"
  #  And I fill in "Work Title" with "Fulfilled Story"
  #  And I fill in "Fandoms" with "Starsky & Hutch"
  #  And I select "Not Rated" from "Rating"
  #  And I check "No Archive Warnings Apply"
  #  And I fill in "content" with "Coding late at night is bad for the brain."
 # When I press "Preview"
 # And I press "Post"
 # Then I should see "Work was successfully posted"
  #  And I should see "For myname"
  #  And I should see "Collections:"
  #  And I should see "Yuletide" within ".meta"
  #  And I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
  # Then I should see "Successfully logged out"

  # mod reveals challenge on Dec 25th
  When I am logged in as "mod1" with password "something"
    And 0 emails should be delivered
    And all emails have been delivered
    And I go to the collections page
    And I follow "Yuletide"
    And I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"
  Given the system processes jobs
    And I wait 3 seconds
  When I reload the page
  # 5 gift notification emails are delivered for the 5 stories that have been posted so far (4 standard, 1 pinch-hit, 1 still a draft)
  Then 5 emails should be delivered
    And the email should contain "A gift story has been posted for you"
    # TODO: Check this capitalisation with someone, since it seems odd to me
    And the email should contain "in the Yuletide collection at the Archive of Our Own"
    And the email should contain "by an anonymous giver"
    And the email should not contain "myname1"
    And the email should not contain "myname2"
    And the email should not contain "myname3"
    And the email should not contain "myname4"
    And the email should not contain "myname5"
    And the email should not contain "myname6"

  # someone views the story they wrote and it is anonymous
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I follow "myname1"
  Then I should see "Fulfilling Story"
    And I should see "Anonymous"
  When I follow "Fulfilling Story"
  Then I should see "For myname"
    And I should see "Collections:"
    And I should see "Yuletide" within ".meta"
    And I should see "Anonymous"
    
  # someone views their gift and it is anonymous
  # Needs everyone to have fulfilled their assignments to be sure of finding a gift
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I follow "myname2"
    And I follow "My Gifts"
  Then I should see "Anonymous"
    And I should not see "myname1"
    And I should not see "myname3"
    And I should not see "myname4"
    And I should not see "myname5"
    And I should not see "myname6"
    And I should not see "pinchhitter"
  When I follow "Fulfilling Story"
  Then I should see the page title "Fulfilling Story - Anonymous - Stargate Atlantis [Example Archive]"
  Then I should see "Anonymous"
    And I should not see "myname1"
    And I should not see "myname3"
    And I should not see "myname4"
    And I should not see "myname5"
    And I should not see "myname6"
    And I should not see "pinchhitter" within ".byline"
    # TODO: Check downloads more thoroughly
  # When I follow "MOBI"
  # Then I should see "Anonymous"
  When I follow "Log out"
  Then I should see "Successfully logged out"

  # mod reveals authors on Jan 1st
  When "issue 1847" is fixed
  # When I follow "Log out"
  When I am logged in as "mod1" with password "something"
  When I am on the collections page
    And I follow "Log out"
    And I am logged in as "mod1" with password "something"
    And I go to the collections page
    And I follow "Yuletide"
    And I follow "Settings"
    And I uncheck "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"

  # someone can now see their writer: will fail intermittently until pinch hitting is fixed above
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And the system processes jobs
    And I follow "myname1"
  Then I should see "Fulfilling Story"
    And I should not see "Anonymous"
  When I follow "Fulfilling Story"
  Then I should not see "Anonymous"
   And I should see "myname" within ".byline"

  When I follow "Post New"
  Then I should not see "Does this fulfill a challenge assignment"
  When I follow "Log out"
    And I am logged in as "pinchhitter" with password "something"
    And I follow "Post New"
  Then I should not see "Does this fulfill a challenge assignment"
  When I follow "Log out"
    And I am logged in as "myname6" with password "something"
    And I follow "Post New"
  Then I should not see "Does this fulfill a challenge assignment"
    