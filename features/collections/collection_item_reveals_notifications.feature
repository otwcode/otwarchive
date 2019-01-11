@collections @promptmemes @giftexchanges @challenges @works @gifts

Feature: Notification emails for individually revealed collection items
  When a moderator reveals or de-anons an individual collection item, the relevant notification emails should be sent.

###################################
#
# MULTIPLE WORKS IN ONE COLLECTION
#
###################################

Scenario: When there are multiple gift works in an unrevealed collection, gift and subscription notifications should only be sent for the particular work that is being revealed, not for works that have not yet been revealed or that have previously been revealed.
  Given the unrevealed collection "Unrevealed Collection"
    And the user "recip1" exists and is activated
    And the user "recip2" exists and is activated
    And the user "recip3" exists and is activated
    And "subscriber1" subscribes to author "creator1"
    And "subscriber2" subscribes to author "creator2"
    And "subscriber3" subscribes to author "creator3"

  # Post the works
  When "creator1" posts the work "Present 1" to the collection "Unrevealed Collection" as a gift for "recip1"
    And "creator2" posts the work "Present 2" to the collection "Unrevealed Collection" as a gift for "recip2"
    And "creator3" posts the work "Present 3" to the collection "Unrevealed Collection" as a gift for "recip3"
  Then 0 emails should be delivered

  # Reveal the first work
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Present 1" in the collection "Unrevealed Collection"
    And subscription notifications are sent
  Then "recip1" should be notified by email about their gift "Present 1"
    And 1 email should be delivered to "subscriber1"
    And 0 emails should be delivered to "recip2"
    And 0 emails should be delivered to "recip3"
    And 0 emails should be delivered to "subscriber2"
    And 0 emails should be delivered to "subscriber3"

  # Reveal the second work
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Present 2" in the collection "Unrevealed Collection"
    And subscription notifications are sent
  Then "recip2" should be notified by email about their gift "Present 2"
    And 1 email should be delivered to "subscriber2"
    And 0 emails should be delivered to "recip1"
    And 0 emails should be delivered to "recip3"
    And 0 emails should be delivered to "subscriber1"
    And 0 emails should be delivered to "subscriber3"

Scenario: When there are multiple prompt fills in an unrevealed collection, prompt fill notifications should only be sent for the particular work that is being revealed, not for works that have not yet been revealed or that have previously been revealed.
  Given basic tags
    And the prompt meme "Unrevealed Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Prompt Meme"
    And I set the collection "Unrevealed Prompt Meme" to unrevealed
    And "prompter1" has submitted a prompt for "Unrevealed Prompt Meme"
    And "prompter2" has submitted a prompt for "Unrevealed Prompt Meme"
    And "prompter3" has submitted a prompt for "Unrevealed Prompt Meme"

  # Post the works fulfilling the prompts
  When I am logged in as "creator"
    And I claim a prompt by "prompter1" from "Unrevealed Prompt Meme"
    And I fulfill my claim with "Fill to Reveal 1"
  Then 0 emails should be delivered
  When I claim a prompt by "prompter2" from "Unrevealed Prompt Meme"
    And I fulfill my claim with "Fill to Reveal 2"
  Then 0 emails should be delivered
  When I claim a prompt by "prompter3" from "Unrevealed Prompt Meme"
    And I fulfill my claim with "Fill to Reveal 3"
  Then 0 emails should be delivered

  # Reveal the first work
  When I am logged in as the owner of "Unrevealed Prompt Meme"
    And I view the approved collection items page for "Unrevealed Prompt Meme"
    And I reveal the work "Fill to Reveal 1" in the collection "Unrevealed Prompt Meme"
  Then 1 email should be delivered to "prompter1"
    And 0 emails should be delivered to "prompter2"
    And 0 emails should be delivered to "prompter3"

  # Reveal the second work
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Prompt Meme"
    And I reveal the work "Fill to Reveal 2" in the collection "Unrevealed Prompt Meme"
  Then 1 email should be delivered to "prompter2"
    And 0 emails should be delivered to "prompter1"
    And 0 emails should be delivered to "prompter3"

Scenario: When there are multiple child works in an unrevealed collection, related work notifications should only be sent for the particular work that is being revealed, not for works that have not yet been revealed or that have previously been revealed.
  Given I have the unrevealed collection "Unrevealed Collection"
    And "inspiration1" posts the work "Inspirational Work 1"
    And "inspiration2" posts the work "Inspirational Work 2"
    And "inspiration3" posts the work "Inspirational Work 3"
  
  # Post the works
  When I am logged in as a random user
    And I set up the draft "Child Work 1" to the collection "Unrevealed Collection"
    And I list the work "Inspirational Work 1" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered to "inspiration1"
  When I set up the draft "Child Work 2" to the collection "Unrevealed Collection"
    And I list the work "Inspirational Work 2" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered to "inspiration1"
  When I set up the draft "Child Work 3" to the collection "Unrevealed Collection"
    And I list the work "Inspirational Work 3" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered to "inspiration3"

  # Reveal the first work
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Child Work 1" in the collection "Unrevealed Collection"
  Then 1 email should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration3"

  # Reveal the second work
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Child Work 2" in the collection "Unrevealed Collection"
  Then 1 email should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration3"

###################################
#
# ONE WORK IN MULTIPLE COLLECTIONS
#
###################################

Scenario: When a gift work is in multiple unrevealed collections, gift and subscription notifications should only be sent after it has been revealed in both collections.
  Given the unrevealed collection "Unrevealed Collection" with name "unrevealed_collection"
    And the unrevealed collection "Hidden Collection" with name "hidden_collection"
    And the user "recip" exists and is activated
    And "subscriber" subscribes to author "creator"

  # Post the work
  When I am logged in as "creator"
    And I set up the draft "Surprise Present" as a gift for "recip"
    And I fill in "Post to Collections / Challenges" with "unrevealed_collection, hidden_collection"
    And I press "Post Without Preview"
    And subscription notifications are sent
  Then 0 emails should be delivered

  # Reveal it in the first collection
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Surprise Present" in the collection "Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered

  # Reveal it in the second collection
  When I am logged in as the owner of "Hidden Collection"
    And I view the approved collection items page for "Hidden Collection"
    And I reveal the work "Surprise Present" in the collection "Hidden Collection"
    And subscription notifications are sent
  Then "recip" should be notified by email about their gift "Surprise Present"
    And 1 email should be delivered to "subscriber"

Scenario: When a prompt fill is posted to an unrevealed collection and an anonymous collection, prompt fill notifications should be sent when the unrevealed work is revealed, and subscription notifications should not be sent until the anonymous collection reveals the creator.
  Given basic tags
    And I have the anonymous collection "Anon Collection"
    And the prompt meme "Unrevealed Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Prompt Meme"
    And I set the collection "Unrevealed Prompt Meme" to unrevealed
    And "prompter" has submitted a prompt for "Unrevealed Prompt Meme"
    And "creator" has claimed a prompt from "Unrevealed Prompt Meme"
    And "subscriber" subscribes to author "creator"
  
  # Post the work
  When I am logged in as "creator"
    And I start to fulfill my claim with "A Work"
    And I fill in "Post to Collections / Challenges" with "anon_collection, unrevealed_prompt_meme"
    And I press "Post Without Preview"
    And subscription notifications are sent
  Then 0 emails should be delivered
  
  # Reveal the work in the first collection
  When I am logged in as the owner of "Unrevealed Prompt Meme"
    And I view the approved collection items page for "Unrevealed Prompt Meme"
    And I reveal the work "A Work" in the collection "Unrevealed Prompt Meme"
    And subscription notifications are sent
  Then 1 email should be delivered to "prompter"
    And 0 emails should be delivered to "subscriber"

  # Reveal the creator of the work in the second
  When all emails have been delivered
    And I am logged in as the owner of "Anon Collection"
    And I view the approved collection items page for "Anon Collection"
    And I reveal the creator of the work "A Work" in the collection "Anon Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber"
    And 0 emails should be delivered to "prompter"

#############################
#
# ONE WORK IN ONE COLLECTION
#
#############################

Scenario: An existing work is edited to simultaneously add a recipient and a collection. The recipient should not be notified of the gift until it is revealed.
  Given the unrevealed collection "Unrevealed Collection" with name "unrevealed_collection"
    And the user "recip" exists and is activated
    And I am logged in as a random user
    And I post the work "Regift"
  
  # Add the recipient and collection
  When I edit the work "Regift"
    And I fill in "Gift this work to" with "recip"
    And I fill in "Post to Collections / Challenges" with "unrevealed_collection"
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  
  # Reveal the work
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Regift" in the collection "Unrevealed Collection"
  Then "recip" should be notified by email about their gift "Regift"
    And the email should contain "Unrevealed Collection"

Scenario: A gift work is posted to a moderated unrevealed collection. The moderator simultaneouesly rejects and reveals the work. One gift notification should be sent and should not include the collection name.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as a random user
    And I post the work "Rejected Work" to the collection "Unrevealed Moderated Collection" as a gift for "recip"
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I reject and reveal the work "Rejected Work" in the collection "Unrevealed Moderated Collection"
  Then "recip" should be notified by email about their gift "Rejected Work"
    And the email should not contain "Unrevealed Moderated Collection"

Scenario: A prompt fill is posted to an anonymous unrevealed collection. A prompt fill notification goes out when the work is revealed and subscription notifications go out when it is de-anoned.
  Given basic tags
    And the prompt meme "Anon Unrevealed Prompt Meme" with default settings
    And I am logged in as the owner of "Anon Unrevealed Prompt Meme"
    And I set the collection "Anon Unrevealed Prompt Meme" to unrevealed
    And I set the collection "Anon Unrevealed Prompt Meme" to anonymous
    And "prompter" has submitted a prompt for "Anon Unrevealed Prompt Meme"
    And "creator" has claimed a prompt from "Anon Unrevealed Prompt Meme"
    And "subscriber" subscribes to author "creator"
  
  # Post the work
  When I am logged in as "creator"
    And I fulfill my claim with "A Work"
    And subscription notifications are sent
  Then 0 emails should be delivered
  
  # Reveal the work
  When I am logged in as the owner of "Anon Unrevealed Prompt Meme"
    And I view the approved collection items page for "Anon Unrevealed Prompt Meme"
    And I reveal the work "A Work" in the collection "Anon Unrevealed Prompt Meme"
    And subscription notifications are sent
  Then 1 email should be delivered to "prompter"
    And 0 emails should be delivered to "subscriber"

  # De-anon the work
  When all emails have been delivered
    And I view the approved collection items page for "Anon Unrevealed Prompt Meme"
    And I reveal the creator of the work "A Work" in the collection "Anon Unrevealed Prompt Meme"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber"
    And 0 emails should be delivered to "prompter"

Scenario: A prompt fill is posted to an anonymous unrevealed collection. The moderator simultaneously rejects, reveals, and de-anons the work. One prompt notification and one subscription notification should be sent.
  Given basic tags
    And the prompt meme "Anon Unrevealed Prompt Meme" with default settings
    And I am logged in as the owner of "Anon Unrevealed Prompt Meme"
    And I set the collection "Anon Unrevealed Prompt Meme" to unrevealed
    And I set the collection "Anon Unrevealed Prompt Meme" to anonymous
    And "prompter" has submitted a prompt for "Anon Unrevealed Prompt Meme"
    And "creator" has claimed a prompt from "Anon Unrevealed Prompt Meme"
    And "subscriber" subscribes to author "creator"
  When I am logged in as "creator"
    And I fulfill my claim with "A Work"
    And subscription notifications are sent
  Then 0 emails should be delivered
  When I am logged in as the owner of "Anon Unrevealed Prompt Meme"
    And I view the approved collection items page for "Anon Unrevealed Prompt Meme"
    And I uncheck "Anonymous"
    And I reject and reveal the work "A Work" in the collection "Anon Unrevealed Prompt Meme"
    And subscription notifications are sent
  Then 1 email should be delivered to "prompter"
    And the email should not contain "Anon Unrevealed Prompt Meme"
    And 1 email should be delivered to "subscriber"

#################################################
#
# MIXED INDIVIDUAL AND COLLECTION SETTING REVEAL
#
#################################################

Scenario: Three gift works are posted to an unrevealed collection. First, the moderator reveals one work by itself, which should just send gift and subscription emails for that one work. Then the moderator reveals the two remaining works by changing the collection setting, which should only send gift and subscription notifications for those two works.
  Given I have the unrevealed collection "Unrevealed Collection"
    And the user "recip1" exists and is activated
    And the user "recip2" exists and is activated
    And the user "recip3" exists and is activated
    And "subscriber1" subscribes to author "creator1"
    And "subscriber2" subscribes to author "creator2"
    And "subscriber3" subscribes to author "creator3"

  # Post the works
  When "creator1" posts the work "Individually Revealed Work" to the collection "Unrevealed Collection" as a gift for "recip1"
    And "creator2" posts the work "Group Revealed Work 1" to the collection "Unrevealed Collection" as a gift for "recip2"
    And "creator3" posts the work "Group Revealed Work 2" to the collection "Unrevealed Collection" as a gift for "recip3"
    And subscription notifications are sent
  Then 0 emails should be delivered

  # Reveal a single work
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Individually Revealed Work" in the collection "Unrevealed Collection"
    And subscription notifications are sent
  Then "recip1" should be notified by email about their gift "Individually Revealed Work"
    And 1 email should be delivered to "subscriber1"
    And 0 emails should be delivered to "recip2"
    And 0 emails should be delivered to "recip3"
    And 0 emails should be delivered to "subscriber2"
    And 0 emails should be delivered to "subscriber3"
  
  # Reveal the remaining works by changing the collection setting
  When all emails have been delivered
    And I reveal works for "Unrevealed Collection"
    And subscription notifications are sent
  Then "recip2" should be notified by email about their gift "Group Revealed Work 1"
    And "recip3" should be notified by email about their gift "Group Revealed Work 2"
    And 1 email should be delivered to "subscriber2"
    And 1 email should be delivered to "subscriber3"
    And 0 emails should be delivered to "recip1"
    And 0 emails should be delivered to "subscriber1"

Scenario: Three related works are posted to an anonymous moderated collection. They are neither approved nor rejected. First, the moderator reveals the creator of one work, which should just send subscription emails for that one work. Then the moderator reveals the two remaining works by changing the collection setting, which should only send subscription notifications for those two works.
  Given I have the anonymous moderated collection "Anon Collection"
    And "inspiration1" posts the work "Inspirational Work 1"
    And "inspiration2" posts the work "Inspirational Work 2"
    And "inspiration3" posts the work "Inspirational Work 3"
    And "subscriber1" subscribes to author "creator1"
    And "subscriber2" subscribes to author "creator2"
    And "subscriber3" subscribes to author "creator3"

  # Post the works, which sends related work emails but no subscription emails
  When I am logged in as "creator1"
    And I set up the draft "Child Work 1" in the collection "Anon Collection"
    And I list the work "Inspirational Work 1" as inspiration
    And I press "Preview"
    And I press "Post"
    And subscription notifications are sent
  Then 1 email should be delivered to "inspiration1"
    And 0 emails should be delivered to "subscriber1"
  When I am logged in as "creator2"
    And I set up the draft "Child Work 2" in the collection "Anon Collection"
    And I list the work "Inspirational Work 2" as inspiration
    And I press "Post Without Preview"
    And subscription notifications are sent
  Then 1 email should be delivered to "inspiration2"
    And 0 emails should be delivered to "subscriber2"
  When I am logged in as "creator3"
    And I set up the draft "Child Work 3" in the collection "Anon Collection"
    And I list the work "Inspirational Work 3" as inspiration
    And I press "Post Without Preview"
    And subscription notifications are sent
  Then 1 email should be delivered to "inspiration3"
    And 0 emails should be delivered to "subscriber3"

  # Reveal the creator of a single work
  When I am logged in as the owner of "Anon Collection"
    And I view the awaiting approval collection items page for "Anon Collection"
    And I reveal the work "Child Work 1" in the collection "Anon Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber1"
    And 0 emails should be delivered to "subscriber2"
    And 0 emails should be delivered to "subscriber3"
    And 0 emails should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration3"
  
  # Reveal the remaining creators by changing the collection setting
  When all emails have been delivered
    And I reveal authors for "Anon Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber2"
    And 1 email should be delivered to "subscriber3"
    And 0 emails should be delivered to "subscriber1"
    And 0 emails should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration3"
