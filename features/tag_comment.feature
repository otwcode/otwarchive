@tags @tag_wrangling
Feature: Comment on tag
As a tag wrangler
I'd like to comment on a tag'

  Scenario: Comment on a tag
    Given I have no users
      And I have no tags
      And the following activated tag wranglers exist
        | login       | password      | email             |
        | dizmo       | wrangulator   | dizmo@example.org |
        | Enigel      | wrangulator   | enigel@example.org|
      And the following admin exists
        | login       | password      |
        | Amelia      | secret        |
      And a fandom exists with name: "Stargate Atlantis", canonical: true
    When I am logged in as "dizmo" with password "wrangulator"
    Then I should see "Hi, dizmo!"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
    When I view the tag "Stargate Atlantis"
    Then I should see "0 comments"
    When I follow "0 comments"
      And I fill in "Comment" with "Shouldn't this be a metatag with Stargate?"
      And I press "Add Comment"
    Then I should see "Comment created!"
      And I should see "Shouldn't this be a metatag with Stargate?"
      And I should see Posted nowish
    When I follow "Edit"
    Then the "Comment" field should contain "Shouldn't this be a metatag with Stargate?"
    When I fill in "Comment" with "Yep, we should have a Stargate franchise metatag."
      And I press "Update"
    Then I should see "Comment was successfully updated."
      And I should see "Yep, we should have a Stargate franchise metatag."
      And I should not see "Shouldn't this be a metatag with Stargate?"
      And I should see Last Edited nowish
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
    
    # admin can also comment on tags, issue 1428 '
    When I follow "Log out"
      And I go to the admin_login page
      And I fill in "admin_session_login" with "Amelia"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
    When I follow "1 comment"
      And I fill in "Comment" with "Important policy decision"
      And I press "Add Comment"
    Then I should see "Comment created!"
    When I view the tag "Stargate Atlantis"
    Then I should see "2 comments"
    
    When I follow "Log out"
      And I am logged in as "dizmo" with password "wrangulator"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
    When I follow "Discussion"
    Then I should see "Tag Wrangling Discussion"
      And I should see "Yep, we should have a Stargate franchise metatag."
      And I should see "Important policy decision"
      
  Scenario: Issue 2185: email notifications for tag commenting; TO DO: replies to comments
  
    Given the following activated tag wranglers exist
        | login       | password      | email             |
        | dizmo       | wrangulator   | dizmo@example.org |
        | Enigel      | wrangulator   | enigel@example.org|
        | Cesy        | wrangulator   | cesy@example.org|
      And a fandom exists with name: "Eroica", canonical: true
      And a fandom exists with name: "Doctor Who", canonical: true
      And the tag wrangler "Enigel" with password "wrangulator" is wrangler of "Eroica"
      And the tag wrangler "Cesy" with password "wrangulator" is wrangler of "Doctor Who"
      And the tag wrangler "dizmo" with password "wrangulator" is wrangler of "Doctor Who"
      
    # receive copies of own comments
    When I am logged in as "Enigel" with password "wrangulator"
      And I go to Enigel's user page
      #'
      And I follow "My Preferences"
      And I uncheck "Turn off copies of your own comments"
      And I press "Update"
      And I follow "Log out"
      
    # fellow wrangler leaves a comment on a wrangler's fandom  
    When I am logged in as "Cesy" with password "wrangulator"
      And I go to Cesy's user page
      #'
      And I follow "My Preferences"
      And I check "Turn off copies of your own comments"
      And I press "Update"
      And all emails have been delivered
      And I view the tag "Eroica"
      And I follow "0 comments"
      And I fill in "Comment" with "really clever stuff"
      And I press "Add Comment"
    Then I should see "Comment created"
      And 1 email should be delivered to "enigel@example.org"
      And the email should contain "really clever stuff"
      And the email should contain "Cesy"
      And the email should contain "left the following comment on"
      
    # check that the links in the email go where they should; this is wonky and I don't know why
    When I follow "Go to the thread starting from this comment" in the email
    # the session is lost for some reason and I have to log in! I'll log in as dizmo though
      And I fill in "User name:" with "dizmo"
      And I fill in "Password:" with "wrangulator"
      And I press "Log in"
    # I get redirected to the tag comments page
    Then I should see "Viewing Comments on Eroica"
      And I should see "really clever stuff"
    When I follow "Read all comments on Eroica" in the email
      And I fill in "User name:" with "Cesy"
      And I fill in "Password:" with "wrangulator"
      And I press "Log in"
    # TO DO: This goes to the dashboard instead of a redirect to the tag! Why, why? I mean, why? Why?
    # Then I should see "Viewing Comments on Eroica"
      # And I should see "really clever stuff"
    When I follow "Reply to this comment" in the email
      And I fill in "User name:" with "Enigel"
      And I fill in "Password:" with "wrangulator"
      And I press "Log in"
    # TO DO: This goes to the dashboard instead of a redirect to the tag!
    # Then I should see "Viewing Comments on Eroica"
      # And I should see "really clever stuff"
    
    When I view the tag "Doctor Who"
      And all emails have been delivered
      And I follow "0 comments"
      And I fill in "Comment" with "really clever stuff"
      And I press "Add Comment"
    Then I should see "Comment created"
      And 1 email should be delivered to "cesy@example.org"
      And 1 email should be delivered to "dizmo@example.org"
      And 1 email should be delivered to "enigel@example.org"
    When I follow "Edit"
      And all emails have been delivered
      And I press "Update"
    Then I should see "Comment was successfully updated"
      And 3 emails should be delivered
      