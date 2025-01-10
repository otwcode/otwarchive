@users
Feature: First login help banner

  Scenario: New user sees the banner
  
  Given I am logged in as "newname"
  When I am on newname's user page
  Then I should see the first login banner
    And I should see "For help getting started on AO3, check out some useful tips for new users or browse through our FAQs."
    And I should see "If you need technical support, contact our Support team. If you experience harassment or have questions about our Terms of Service (including the Content Policy and Privacy Policy), contact our Policy & Abuse team."
  When I follow "our FAQs"
  Then I should be on the faq page
  When I am on newname's user page
    And I follow "contact our Support team"
  Then I should be on the support page
  When I am on newname's user page
    And I follow "Terms of Service"
  Then I should be on the tos page
  When I am on newname's user page
    And I follow "Content Policy"
  Then I should be on the content page
  When I am on newname's user page
    And I follow "Privacy Policy"
  Then I should be on the privacy page
  When I am on newname's user page
    And I follow "contact our Policy & Abuse team"
  Then I should see "Policy Questions & Abuse Reports"

  Scenario: Popup details can be viewed
  
  Given I am logged in as "newname"
  When I am on newname's user page
  When I follow "useful tips for new users"
  Then I should see the first login popup

  Scenario: Turn off first login help banner directly

  Given I am logged in as "newname2"
  When I am on newname2's user page
  When I press "Dismiss permanently"
  Then I should not see the first login banner
  
  Scenario: Banner stays off after logout and login if turned off directly
  
  Given I am logged in as "newname2"
  When I am on newname2's user page
  When I press "Dismiss permanently"
  When I am logged out
    And I am logged in as "newname2"
  Then I should not see the first login banner
  When I am on newname2's user page
  Then I should not see the first login banner
  
  Scenario: Hide banner using X
  
  Given I am logged in as "newname2"
  When I am on newname2's user page
  # Note this is "&times;" and not a letter "x"
  When I follow "×" within "div#main"
  
  Scenario: Banner comes back if turned off using X
  
  Given I am logged in as "newname2"
  When I am on newname2's user page
  # Note this is "&times;" and not a letter "x"
  When I follow "×" within "div#main"
  When I am logged out
    And I am logged in as "newname2"
    And I am on my user page
  Then I should see the first login banner
