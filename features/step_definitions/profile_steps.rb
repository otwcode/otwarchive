When /^I view my profile$/ do
	click_link("testuser1")
  Then %{I should see "My Dashboard"}
	click_link("Profile")
end


When /^I edit my profile$/ do
  click_link("Profile")
		And %{I should see "About editname"}
    And %{I should not see "Test title thingy"}
    And %{I should not see "Location"}
    And %{I should not see "This is some text about me"}
		click_link("Edit My Profile")
		And %{I should see "Edit My Profile"}
end


When /^I fill in my profile$/ do
	fill_in("Title", :with => "Test title thingy")
  fill_in("Location", :with => "Alpha Centauri")
  fill_in("About Me", :with => "This is some text about me.")  
  click_button("Update")
end


  
When /^I change the details in my profile$/ do
  fill_in("Title", :with => "Alternative title thingy")
  fill_in("Location", :with => "Beta Centauri")
  fill_in("About Me", :with => "This is some different text about me.") 
  click_button("Update")
end


When /^I remove details from my profile$/ do
  fill_in("Title", :with => "")
  fill_in("Location", :with => "")
	fill_in("About Me", :with => "")
  click_button("Update")
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
  click_link("Profile")
  click_link("Edit My Profile")
  And %{I fill in "Change Email" with "valid2@archiveofourown.org"}
  And %{I fill in "Old password" with "password"}
  And %{I press "Update"}
end


When /^I change my preferences to display my date of birth$/ do
 click_link("My Preferences")
	And %{I check "Display Date of Birth"}
  And %{I press "Update"}
  click_link("editname")
  click_link("Profile")
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
  fill_in("New Password", :with => "newpass1")
  And %{I fill in "Confirm New Password" with "newpass1"}
  And %{I fill in "Old password" with "password"}
  And %{I press "Change Password"}
end


When /^I make a new pseud$/ do
 click_link("New Pseud")
   And %{I should see "New pseud"}
  Then %{I fill in "Name" with "My new name"}
    And %{I fill in "Description" with "I wanted to add another name"}
    And %{I press "Create"}
end
