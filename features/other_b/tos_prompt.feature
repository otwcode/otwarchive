@javascript
Feature: Terms of Service prompt
  As a user
  I need to agree to the terms of service

  Scenario: Terms of Service prompt is displayed
    Given the terms of service prompt is enabled
    When I am on the works page
    Then I should see "To learn more, check out our Terms of Service"

  Scenario: Terms of Service prompt does not reappear after being filled out
    Given the terms of service prompt is enabled
    When I am on the works page
    Then I should see "To learn more, check out our Terms of Service"
    When I check "I have read & understood the 2024 Terms of Service, including the Content Policy and Privacy Policy."
      And I check "By checking this box, you consent to the processing of your personal data in the United States and other jurisdictions in connection with our provision of AO3 and its related services to you. You acknowledge that the data privacy laws of such jurisdictions may differ from those provided in your jurisdiction. For more information about how your personal data will be processed, please refer to our Privacy Policy."
      And I press "I agree/consent to these Terms"
    Then I should not see "To learn more, check out our Terms of Service"
    When I go to the media page
    Then I should not see "To learn more, check out our Terms of Service"
