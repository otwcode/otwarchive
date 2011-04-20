When /^I am editing my profile$/ do
  Then %{I follow "Profile"}
		And %{I should see "About editname"}
    And %{I should not see "Test title thingy"}
    And %{I should not see "Location"}
    And %{I should not see "This is some text about me"}
	Then %{I follow "Edit My Profile"}
		And %{I should see "Edit My Profile"}
end


When /^I change my email$/ do
  Then %{I fill in "Old password" with "password"}
		And %{I fill in "Change Email" with "valid2@archiveofourown.org"}
    And %{I press "Update"}
end

		
When /^I enter an invalid email$/ do
	Then %{I fill in "Old password" with "password"}
		And %{I fill in "Change Email" with "bob.bob.bob"}
		And %{I press "Update"}
end


When /^I enter a duplicate email$/ do
  Then %{I follow "Profile"}
  And %{I follow "Edit My Profile"}
  And %{I fill in "Change Email" with "valid2@archiveofourown.org"}
  And %{I fill in "Old password" with "password"}
  And %{I press "Update"}
	Then %{I should not see "Your profile has been successfully updated"}
end


When /^I check my date of birth$/ do
  And %{I press "Update"}
  And %{I follow "editname"}
  And %{I follow "Profile"}
end


When /^I change my date of birth$/ do
	And %{I select "1998" from "profile_attributes[date_of_birth(1i)]"}
  And %{I select "December" from "profile_attributes[date_of_birth(2i)]"}
  And %{I select "31" from "profile_attributes[date_of_birth(3i)]"}
  And %{I press "Update"}
  Then %{I should not see "Your profile has been successfully updated"}
  And %{I should see "You must be over 13"}
  When %{I select "1980" from "profile_attributes[date_of_birth(1i)]"}
    And %{I press "Update"}
end


When /^I change my password$/ do
  Then %{I fill in "New Password" with "newpass1"}
  And %{I fill in "Confirm New Password" with "newpass1"}
  And %{I fill in "Old password" with "password"}
  And %{I press "Change Password"}
end


When /^I make a new pseud$/ do
 Then %{I follow "New Pseud"}
   And %{I should see "New pseud"}
  Then %{I fill in "Name" with "My new name"}
    And %{I fill in "Description" with "I wanted to add another name"}
    And %{I press "Create"}
end