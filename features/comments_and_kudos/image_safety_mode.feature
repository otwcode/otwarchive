Feature: Image safety mode
  In order to protect users
  As a site owner
  I'd like to control which comments can include images

  Scenario Outline: Images are embedded in comments when image safety mode is off.
    Given the setup for testing image safety mode on <commentable>
      And image safety mode is disabled for comments
    When I view <commentable> with comments
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! https://example.com/image.jpg"
    When I go to the homepage
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! https://example.com/image.jpg"
    When I go to my inbox page
    Then I should see the image "src" text "https://example.com/image.jpg"
    When image safety mode is enabled for comments on a "<parent_type>"
      And I view <commentable> with comments
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"
    When I go to the homepage
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"
    When I go to my inbox page
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"

    Examples:
      | commentable                 | parent_type |
      | the admin post "Change Log" | AdminPost   |
      | the work "My Opus"          | Chapter     |
      | the tag "No Fandom"         | Tag         |

  Scenario Outline: Embedded images in comments are replaced with their URLs when image safety mode is enabled.
    Given the setup for testing image safety mode on <commentable>
      And image safety mode is enabled for comments on a "<parent_type>"
    When I view <commentable> with comments
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"
    When I go to the homepage
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"
    When I go to my inbox page
    Then I should not see the image "src" text "https://example.com/image.jpg"
      But I should see "OMG! https://example.com/image.jpg"
    When image safety mode is disabled for comments
      And I view <commentable> with comments
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! https://example.com/image.jpg"
    When I go to the homepage
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! https://example.com/image.jpg"
    When I go to my inbox page
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! https://example.com/image.jpg"

    Examples:
      | parent_type | commentable                 |
      | AdminPost   | the admin post "Change Log" |
      | Chapter     | the work "My Opus"          |
      | Tag         | the tag "No Fandom"         |

