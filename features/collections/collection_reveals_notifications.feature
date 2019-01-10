@collections @promptmemes @giftexchanges @challenges @works @gifts

Feature: Notification emails for newly revealed collections
  When a moderator reveals or de-anons an entire collection, the relevant notification emails should be sent.

  #########################################
  #
  # WORKS POSTED DIRECTLY TO THE COLLECTION
  #
  #########################################

  Scenario: A creator posts a gift work to a moderated unrevealed collection. The moderator does not approve or reject the work before revealing the collection. Gift notifications for the work should be sent, but should not mention the collection name.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as a random user
    And I post the work "Unapproved Work" to the collection "Unrevealed Moderated Collection" as a gift for "recip"
  When I reveal works for "Unrevealed Moderated Collection"
  Then "recip" should be notified by email about their gift "Unapproved Work"
    And the email should not contain "Unrevealed Moderated Collection"
  When I am logged in as "recip"
  Then the work "Unapproved Work" should be visible to me

  Scenario: A creator posts a gift work to a moderated unrevealed collection. The moderator rejects the work before revealing the collection. Gift notifications for the work should be sent, but should not mention the collection name.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as a random user
    And I post the work "Rejected Work" to the collection "Unrevealed Moderated Collection" as a gift for "recip"
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I reject the collection item for the work "Rejected Work"
    And I reveal works for "Unrevealed Moderated Collection"
  Then "recip" should be notified by email about their gift "Rejected Work"
    And the email should not contain "Unrevealed Moderated Collection"
  When I am logged in as "recip"
  Then the work "Rejected Work" should be visible to me

  Scenario: A creator posts a gift work to a moderated unrevealed collection. The moderator approves the work before revealing the collection. Gift notifications for the work should be sent and should mention the collection name.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as a random user
    And I post the work "Approved Work" to the collection "Unrevealed Moderated Collection" as a gift for "recip"
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I approve the collection item for the work "Approved Work"
    And I reveal works for "Unrevealed Moderated Collection"
  Then "recip" should be notified by email about their gift "Approved Work"
    And the email should contain "Unrevealed Moderated Collection"
  When I am logged in as "recip"
  Then the work "Approved Work" should be visible to me

  Scenario: A creator posts a related work to a moderated unrevealed collection. The moderator does not approve or reject the work before revealing the collection. Related work notifications for the work should be sent. Note: Related work emails never include a collection name, so we don't need to worry about that.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as "inspiration"
    And I post the work "Inspirational Work"
  When I am logged in as a random user
    And I set up the draft "Unapproved Work" to the collection "Unrevealed Moderated Collection"
    And I list the work "Inspirational Work" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When I reveal works for "Unrevealed Moderated Collection"
  Then 1 email should be delivered to "inspiration"
  When I am logged in as "inspiration"
  Then the work "Unapproved Work" should be visible to me

  Scenario: A creator posts a related work to a moderated unrevealed collection. The moderator rejects the work before revealing the collection. Related work notifications for the work should be sent. Note: Related work emails never include a collection name, so we don't need to worry about that.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as "inspiration"
    And I post the work "Inspirational Work"
  When I am logged in as a random user
    And I set up the draft "Rejected Work" to the collection "Unrevealed Moderated Collection"
    And I list the work "Inspirational Work" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I reject the collection item for the work "Rejected Work"
    And I reveal works for "Unrevealed Moderated Collection"
  Then 1 email should be delivered to "inspiration"
  When I am logged in as "inspiration"
  Then the work "Rejected Work" should be visible to me

  Scenario: A creator posts a related work to a moderated unrevealed collection. The moderator approves the work before revealing the collection. Related work notifications for the work should be sent. Note: Related work emails never include a collection name, so we don't need to worry about that.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as "inspiration"
    And I post the work "Inspirational Work"
  When I am logged in as a random user
    And I set up the draft "Approved Work" to the collection "Unrevealed Moderated Collection"
    And I list the work "Inspirational Work" as inspiration
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I approve the collection item for the work "Approved Work"
    And I reveal works for "Unrevealed Moderated Collection"
  Then 1 email should be delivered to "inspiration"
  When I am logged in as "inspiration"
  Then the work "Approved Work" should be visible to me

  Scenario: A creator posts a prompt fill to a moderated unrevealed collection. The moderator does not approve or reject the work before revealing the collection. Prompt notifications for the work should be sent, but should not mention the collection name.
  Given basic tags
    And the prompt meme "Unrevealed Moderated Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I set the collection "Unrevealed Moderated Prompt Meme" to unrevealed
    And I set the collection "Unrevealed Moderated Prompt Meme" to moderated
    And "prompter" has submitted a prompt for "Unrevealed Moderated Prompt Meme"
    And "creator" has claimed a prompt from "Unrevealed Moderated Prompt Meme"
  When I am logged in as "creator"
    And I fulfill my claim
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I reveal works for "Unrevealed Moderated Prompt Meme"
  Then 1 email should be delivered to "prompter"
    And the email should not contain "Unrevealed Moderated Prompt Meme"

  Scenario: A creator posts a prompt fill to a moderated unrevealed collection. The moderator rejects the work before revealing the collection. Prompt notifications for the work should be sent, but should not mention the collection name.
  Given basic tags
    And the prompt meme "Unrevealed Moderated Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I set the collection "Unrevealed Moderated Prompt Meme" to unrevealed
    And I set the collection "Unrevealed Moderated Prompt Meme" to moderated
    And "prompter" has submitted a prompt for "Unrevealed Moderated Prompt Meme"
    And "creator" has claimed a prompt from "Unrevealed Moderated Prompt Meme"
  When I am logged in as "creator"
    And I fulfill my claim with "Rejected Work"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Prompt Meme"
    And I reject the collection item for the work "Rejected Work"
    And I reveal works for "Unrevealed Moderated Prompt Meme"
  Then 1 email should be delivered to "prompter"
    And the email should not contain "Unrevealed Moderated Prompt Meme"

  Scenario: A creator posts a prompt fill to a moderated unrevealed collection. The moderator approves the work before revealing the collection. Prompt notifications for the work should be sent and should mention the collection name.
  Given basic tags
    And the prompt meme "Unrevealed Moderated Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I set the collection "Unrevealed Moderated Prompt Meme" to unrevealed
    And I set the collection "Unrevealed Moderated Prompt Meme" to moderated
    And "prompter" has submitted a prompt for "Unrevealed Moderated Prompt Meme"
    And "creator" has claimed a prompt from "Unrevealed Moderated Prompt Meme"
  When I am logged in as "creator"
    And I fulfill my claim with "Approved Work"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Moderated Prompt Meme"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Prompt Meme"
    And I approve the collection item for the work "Approved Work"
    And I reveal works for "Unrevealed Moderated Prompt Meme"
  Then 1 email should be delivered to "prompter"
    And the email should contain "Unrevealed Moderated Prompt Meme"

  Scenario: A creator posts a work to a moderated anonymous collection. The moderator does not approve or reject the work before de-anoning the collection. A subscription email should be sent.
  Given the user "creator" exists and is activated
    And I have the anonymous moderated collection "Anonymous Moderated Collection"
    And "subscriber" subscribes to author "creator"
  When I am logged in as "creator"
    And I post the work "Unapproved Work" to the collection "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered to "subscriber"
  When I reveal authors for "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber"

  Scenario: A creator posts a work to a moderated anonymous collection. The moderator rejects the work before de-anoning the collection. A subscription email should be sent.
  Given the user "creator" exists and is activated
    And I have the anonymous moderated collection "Anonymous Moderated Collection"
    And "subscriber" subscribes to author "creator"
  When I am logged in as "creator"
    And I post the work "Rejected Work" to the collection "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered to "subscriber"
  When I am logged in as the owner of "Anonymous Moderated Collection"
    And I view the awaiting approval collection items page for "Anonymous Moderated Collection"
    And I reject the collection item for the work "Rejected Work"
    And subscription notifications are sent
  Then 0 emails should be delivered to "subscriber"
  When I reveal authors for "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber"

  Scenario: A creator posts a work to a moderated anonymous collection. The moderator approves the work before de-anoning the collection. A subscription email should be sent.
  Given the user "creator" exists and is activated
    And I have the anonymous moderated collection "Anonymous Moderated Collection"
    And "subscriber" subscribes to author "creator"
  When I am logged in as "creator"
    And I post the work "Approved Work" to the collection "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered to "subscriber"
    When I am logged in as the owner of "Anonymous Moderated Collection"
    And I view the awaiting approval collection items page for "Anonymous Moderated Collection"
    And I approve the collection item for the work "Approved Work"
    And subscription notifications are sent
  Then 0 emails should be delivered to "subscriber"
  When I reveal authors for "Anonymous Moderated Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "subscriber"

  ################
  #
  # INVITED WORKS
  #
  ################

  Scenario: A gift related work is invited to a collection and the creator neither rejects nor approves the invitation. The collection is then made unrevealed and anonymous, which marks the collection item (but not the work) unrevealed and anonymous. When the collection is later revealed and de-anoned, no notifications should be sent for the work.
  Given the user "recip" exists and is activated
    And the user "creator" exists and is activated
    And "subscriber" subscribes to author "creator"
    And I have the collection "Future Anon Unrevealed Collection"
    And I am logged in as "inspiration"
    And I post the work "Inspirational Work"
    And I am logged in as "creator"
  When I set up the draft "Invited Work" as a gift for "recip"
    And I list the work "Inspirational Work" as inspiration
    # HACK: AO3-2373 means related work emails don't always go out when posting without preview
    And I press "Preview"
    And I press "Post"
    And subscription notifications are sent
  Then 1 email should be delivered to "recip"
    And 1 email should be delivered to "inspiration"
    And 1 email should be delivered to "subscriber"
  When all emails have been delivered
    And I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I add the work "Invited Work" to the collection "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "creator"
    And 0 emails should be delivered to "inspiration"
    And 0 emails should be delivered to "recip"
    And 0 emails should be delivered to "subscriber"
  When all emails have been delivered
    And I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I set the collection "Future Anon Unrevealed Collection" to unrevealed
    And I set the collection "Future Anon Unrevealed Collection" to anonymous
    And I am logged out
  # Setting the collection to unrevealed and anonymous should not have hidden the work or its creator
  Then the work "Invited Work" should be visible to me
    And the author of "Invited Work" should be publicly visible
  When I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I reveal works for "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered
  When I reveal authors for "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered

  Scenario: A gift related work is invited to a collection and the moderator changes their mind and rejects the work. The collection is then made anonymous and unrevealed, which marks the collection item (but not the work) anonymous unrevealed. When the collection is later revealed and de-anoned, no notifications should be sent for the work.
  Given the user "recip" exists and is activated
    And the user "creator" exists and is activated
    And "subscriber" subscribes to author "creator"
    And I have the collection "Future Anon Unrevealed Collection"
    And I am logged in as "inspiration"
    And I post the work "Inspirational Work"
    And I am logged in as "creator"
  When I set up the draft "Invited Work" as a gift for "recip"
    And I list the work "Inspirational Work" as inspiration
    # HACK: AO3-2373 means related work emails don't always go out when posting without preview
    And I press "Preview"
    And I press "Post"
    And subscription notifications are sent
  Then 1 email should be delivered to "recip"
    And 1 email should be delivered to "inspiration"
    And 1 email should be delivered to "subscriber"
  When all emails have been delivered
    And I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I add the work "Invited Work" to the collection "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 1 email should be delivered to "creator"
    And 0 emails should be delivered to "inspiration"
    And 0 emails should be delivered to "recip"
    And 0 emails should be delivered to "subscriber"
  When all emails have been delivered
    # Reject the item while logged in as the moderator
    And I view the invited collection items page for "Future Anon Unrevealed Collection"
    And I reject the collection item for the work "Invited Work"
    And subscription notifications are sent
  Then 0 emails should be delivered
  # Reject the invitation while logged in as the creator
  When I am logged in as "creator"
    And I reject the invitation for my work in the collection "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered
  When I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I set the collection "Future Anon Unrevealed Collection" to unrevealed
    And I set the collection "Future Anon Unrevealed Collection" to anonymous
    And I am logged out
  # Setting the collection to unrevealed and anonymous should not have hidden the work or its creator
  Then the work "Invited Work" should be visible to me
    And the author of "Invited Work" should be publicly visible
  When I am logged in as the owner of "Future Anon Unrevealed Collection"
    And I reveal works for "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered
  When I reveal authors for "Future Anon Unrevealed Collection"
    And subscription notifications are sent
  Then 0 emails should be delivered
