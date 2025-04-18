@admin
Feature: Admin spam management
  In order to manage spam works
  As an an admin
  I want to be able to view and update works marked as spam

Scenario: Review spam when spam works are already hidden
  Given the following admin settings are configured:
    | hide_spam | 1 |
    And the spam work "Spammity Spam"
    And the spam work "Totally Legit"
    And the work "Spammity Spam" should be hidden
    And the work "Totally Legit" should be hidden
    And I am logged in as a "superadmin" admin
    And all emails have been delivered
  Then I should see "Spam"
  When I follow "Spam"
  Then I should see "Works Marked as Spam"
    And I should see "Spammity"
    And I should see "Totally Legit"
  When I check "spam_1"
    And I check "ham_2"
    And I press "Update Works"
  Then I should not see "Spammity"
    And I should not see "Totally Legit"
    And the work "Spammity Spam" should be hidden
    And the work "Totally Legit" should not be hidden
    And 0 emails should be delivered


Scenario: Review spam when spam works are not already hidden
  Given the following admin settings are configured:
    | hide_spam | 0 |
    And the spam work "Spammity Spam"
    And the spam work "Totally Legit"
    And the work "Spammity Spam" should not be hidden
    And the work "Totally Legit" should not be hidden
    And I am logged in as a "superadmin" admin
    And all emails have been delivered
  Then I should see "Spam"
  When I follow "Spam"
  Then I should see "Works Marked as Spam"
    And I should see "Spammity"
    And I should see "Totally Legit"
  When I check "spam_3"
    And I check "ham_4"
    And I press "Update Works"
  Then I should not see "Spammity"
    And I should not see "Totally Legit"
    And the work "Spammity Spam" should be hidden
    And the work "Totally Legit" should not be hidden
    And 1 email should be delivered
    And the email should contain "has been flagged by our automated system as spam"

Scenario: Translated work hidden as spam email
  Given I am logged in as "spammer"
    And the work "Spammity Spam Work" by "spammer"
    And a locale with translated emails
    And the user "spammer" enables translated emails
    And I add the co-author "Another" to the work "Spammity Spam Work"
  When I am logged in as a "policy_and_abuse" admin
    And all emails have been delivered
    And I view the work "Spammity Spam Work"
  Then I should see "Mark As Spam"
  When I follow "Mark As Spam"
  Then I should see "marked as spam and hidden"
    And I should see "Mark Not Spam"
    And the work "Spammity Spam Work" should be marked as spam
    And the work "Spammity Spam Work" should be hidden
    And 2 emails should be delivered
    And the email to "spammer" should contain "has been flagged by our automated system as spam"
    And the email to "spammer" should be translated
    And the email to "Another" should contain "has been flagged by our automated system as spam"
    And the email to "Another" should be non-translated
