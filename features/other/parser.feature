@works
Feature: Parsing HTML

  # tests for parsing only are in spec/lib/html_cleaner_spec.rb

  Scenario: Editing a work and saving it without changes should preserve the same content
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is paragraph 1.

    This is paragraph 2.
    """
    And I press "Preview"
  Then I should see "Preview"
    And I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"
  When I press "Post"
   And I follow "Edit"
   And I press "Preview"
  Then I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"

  
  Scenario: HTML Parser should kick in
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    A paragraph

    Another paragraph.
    """
    And I press "Preview"
  Then I should see "Preview"
    And I should see the text with tags "<p>A paragraph</p><p>Another paragraph.</p>" 


