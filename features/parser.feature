@works
Feature: Parsing HTML

  Scenario: Newlines should correctly be converted into paragraph breaks

  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is paragraph 1.

    This is paragraph 2.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>" 
    

  Scenario: Single newlines should correctly be converted into br tags

  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is the first line.
    This is the second line.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>This is the first line.<br />This is the second line.</p>"
  
  
  Scenario: Three newlines should be converted to paragraph with nbsp in the middle
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is the first line.
    
    
    
    This is the second line.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>This is the first line.</p><p> </p><p>This is the second line.</p>"


  
  Scenario: Unclosed tags should correctly be closed
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    Here is an unclosed <em>em tag.
    
    Here is an unclosed <strong>strong tag.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>Here is an unclosed <em>em tag.</em></p>"
    And I should see the text with tags "<p>Here is an unclosed <strong>strong tag.</strong></p>" 
  
  
  
  Scenario: Misnested tags should be correctly re-nested
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    Here is <em><strong>a misnested pair of em and strong tags</em></strong>.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>Here is <em><strong>a misnested pair of em and strong tags</strong></em>.</p>" 
  
  
  Scenario: Editing a work and saving it without changes should preserve the same content
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is paragraph 1.

    This is paragraph 2.    
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"
  When I press "Post"
   And I follow "Edit"
   And I press "Preview"
  Then I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"
  
  
  Scenario: We should reopen tags that were not closed before the end of the paragraph
  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    Here is an <em>em tag.
    
    It continues to</em> the next paragraph.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>Here is an <em>em tag.</em></p><p><em>It continues to</em> the next paragraph.</p>" 
  When I press "Edit"
    And I fill in "content" with
    """
    Here is <em>another</p><p align=center>that has formatting tags</em>
    
    but <em>in
    
    different</em> places and <em>some are closed</em>.
    """
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see the text with tags "<p>Here is <em>another</em></p><p align=\"center\"><em>that has formatting tags</em></p><p>but <em>in</em></p><p><em>different</em> places and <em>some are closed</em>.</p>"


  Scenario: German quotation marks should be kept intact

  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with "„Great words,“ he said. ‚Thinky thoughts,‘ she thought."
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see "„Great words,“ he said. ‚Thinky thoughts,‘ she thought."
