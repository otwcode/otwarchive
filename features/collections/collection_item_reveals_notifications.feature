@collections @promptmemes @giftexchanges @challenges @works @gifts

Feature: Notification emails for individually revealed collection items
  When a moderator reveals an individual collection item, the relevant
  notification emails should be sent.

Scenario: Notify a recipient when a gift work for them is revealed. Do not
notify the recipients of gifts that have not yet been revealed or that have
previously been revealed.
  Given the unrevealed collection "Unrevealed Collection"
    And the user "previous_recip" exists and is activated
    And the user "future_recip" exists and is activated
    And the user "recip" exists and is activated
  When I am logged in as a random user
    And I post the work "Previous Surprise Present" to the collection "Unrevealed Collection" as a gift for "previous_recip"
    And I post the work "Surprise Present" to the collection "Unrevealed Collection" as a gift for "recip"
    And I post the work "Future Surprise Present" to the collection "Unrevealed Collection" as a gift for "future_recip"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Previous Surprise Present" in the collection "Unrevealed Collection"
  Then "previous_recip" should be notified by email about their gift "Previous Surprise Present"
    And 0 emails should be delivered to "recip"
    And 0 emails should be delivered to "future_recip"
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Surprise Present" in the collection "Unrevealed Collection"
  Then "recip" should be notified by email about their gift "Surprise Present"
    And 0 emails should be delivered to "previous_recip"
    And 0 emails should be delivered to "future_recip"

Scenario: Do not notify a recipient if a gift work previously posted for them is
later added to an unrevealed collection. Note: They will be notified when the
gift is revealed.
  Given the unrevealed collection "Unrevealed Collection"
    And the user "recip" exists and is activated
  When I am logged in as a random user
    And I post the work "Present" as a gift for "recip"
  Then "recip" should be notified by email about their gift "Present"
  When all emails have been delivered
    And I add the work "Present" to the collection "Unrevealed Collection"
  Then 0 emails should be delivered 

Scenario: Do not notify a recipient if a previously posted work is given to them
at the same time it is added to an unrevealed collection. Note: They will be
notified when the gift is revealed.
  Given the unrevealed collection "Unrevealed Collection" with name "unrevealed_collection"
    And the user "recip" exists and is activated
    And I am logged in as a random user
    And I post the work "Regift"
  When I edit the work "Regift"
    And I fill in "Gift this work to" with "recip"
    And I fill in "Post to Collections / Challenges" with "unrevealed_collection"
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Regift" in the collection "Unrevealed Collection"
  Then "recip" should be notified by email about their gift "Regift"  

Scenario: Notify a prompter when a response to their prompt is revealed. Do not
notify the prompter of responses that have not yet been revealed or that have
previously been revealed.
  Given basic tags
    And the prompt meme "Unrevealed Prompt Meme" with default settings
    And I am logged in as the owner of "Unrevealed Prompt Meme"
    And I set the collection "Unrevealed Prompt Meme" to unrevealed
    And "prompter1" has submitted a prompt for "Unrevealed Prompt Meme"
    And "prompter2" has submitted a prompt for "Unrevealed Prompt Meme"
    And "prompter3" has submitted a prompt for "Unrevealed Prompt Meme"
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
  When I am logged in as the owner of "Unrevealed Prompt Meme"
    And I view the approved collection items page for "Unrevealed Prompt Meme"
    And I reveal the work "Fill to Reveal 1" in the collection "Unrevealed Prompt Meme"
  Then 1 email should be delivered to "prompter1"
    And 0 emails should be delivered to "prompter2"
    And 0 emails should be delivered to "prompter3"
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Prompt Meme"
    And I reveal the work "Fill to Reveal 2" in the collection "Unrevealed Prompt Meme"
  Then 1 email should be delivered to "prompter2"
    And 0 emails should be delivered to "prompter1"
    And 0 emails should be delivered to "prompter3"

Scenario: Notify a creator when a work inspired by one of their works is
revealed. Do not notify the creators of child works that have not yet been
revealed or that have previously been revealed.
  Given I have the unrevealed collection "Unrevealed Collection"
    And I am logged in as "inspiration1"
    And I post the work "Inspirational Work 1"
    And I am logged in as "inspiration2"
    And I post the work "Inspirational Work 2"
    And I am logged in as "inspiration3"
    And I post the work "Inspirational Work 3"
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
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Child Work 1" in the collection "Unrevealed Collection"
  Then 1 email should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration3"
  When all emails have been delivered
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Child Work 2" in the collection "Unrevealed Collection"
  Then 1 email should be delivered to "inspiration2"
    And 0 emails should be delivered to "inspiration1"
    And 0 emails should be delivered to "inspiration3" 

Scenario: If a gift work is in multiple unrevealed collections, the recipient
should only be notified after it has been revealed in both collections
  Given the unrevealed collection "Unrevealed Collection" with name "unrevealed_collection"
    And the unrevealed collection "Hidden Collection" with name "hidden_collection"
    And the user "recip" exists and is activated
  When I am logged in as a random user
    And I set up the draft "Surprise Present" as a gift for "recip"
    And I fill in "Post to Collections / Challenges" with "unrevealed_collection, hidden_collection"
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Surprise Present" in the collection "Unrevealed Collection"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Hidden Collection"
    And I view the approved collection items page for "Hidden Collection"
    And I reveal the work "Surprise Present" in the collection "Hidden Collection"
  Then "recip" should be notified by email about their gift "Surprise Present"

Scenario: A gift work is posted to a moderated unrevealed collection. The moderator rejects the work and reveals it simultaneously. One gift notification should be sent.
  Given the user "recip" exists and is activated
    And I have the unrevealed moderated collection "Unrevealed Moderated Collection"
    And I am logged in as a random user
    And I post the work "Rejected Work" to the collection "Unrevealed Moderated Collection" as a gift for "recip"
  When I am logged in as the owner of "Unrevealed Moderated Collection"
    And I view the awaiting approval collection items page for "Unrevealed Moderated Collection"
    And I reject and reveal the work "Rejected Work" in the collection "Unrevealed Moderated Collection"
  Then "recip" should be notified by email about their gift "Rejected Work"
