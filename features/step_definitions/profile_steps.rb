Given /^I want to edit my profile$/ do
  click_link("Profile")
	click_link("Edit My Profile")
	And %{I should see "Edit My Profile"}
end


When /^I fill in the details of my profile$/ do
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


When /^I enter an incorrect password$/ do
  fill_in("Old password", :with => "passw")
  click_button("Update")
end


When /^I change my email$/ do
  fill_in("Old password", :with => "password")
	fill_in("Change Email", :with => "valid2@archiveofourown.org")
	click_button("Update")
end


When /^I view my profile$/ do
	click_link("testuser1")
  Then %{I should see "My Dashboard"}
	click_link("Profile")
end

		
When /^I enter an invalid email$/ do
	fill_in("Old password", :with => "password")
	fill_in("Change Email", :with => "bob.bob.bob")	
	click_button("Update")
end


When /^I enter a duplicate email$/ do
  user = Factory.create(:user, :login => "testuser2", :password => "password", :email => "foo@ao3.org")
  user.activate
  fill_in("Change Email", :with => "foo@ao3.org")
  fill_in("Old password", :with => "password") 
  click_button("Update")
end


When /^I enter a birthdate that shows I am under age$/ do
   select("1998", :from => "profile_attributes[date_of_birth(1i)]")
	 select("December", :from => "profile_attributes[date_of_birth(2i)]")
	 select("31", :from => "profile_attributes[date_of_birth(3i)]")
   click_button("Update")
end
	

When /^I change my preferences to display my date of birth$/ do
 click_link("My Preferences")
 check ("Display Date of Birth")
 click_button("Update")
 click_link("testuser1")
 click_link("Profile")
end


When /^I change my preferences to display my email address$/ do
 click_link("My Preferences")
 check ("Display Email Address")
 click_button("Update")
 click_link("testuser1")
 click_link("Profile")
end


When /^I fill in my date of birth$/ do
   select("1980", :from => "profile_attributes[date_of_birth(1i)]")
	 select("November", :from => "profile_attributes[date_of_birth(2i)]")
	 select("30", :from => "profile_attributes[date_of_birth(3i)]")
   click_button("Update")
end


When /^I make a mistake typing my old password$/ do
  click_link("Change My Password")
  fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass1")
  fill_in("Old password", :with => "wrong")
  click_button("Change Password")
end


When /^I make a typing mistake confirming my new password$/ do
	click_link("Change My Password")
	fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass2")
  fill_in("Old password", :with => "password")
  click_button("Change Password")
end


When /^I change my password$/ do
	click_link("Change My Password")
  fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass1")
  fill_in("Old password", :with => "password")
  click_button("Change Password")
end


When /^I make a new pseud$/ do
 click_link("New Pseud")
   And %{I should see "New pseud"}
  Then %{I fill in "Name" with "My new name"}
    And %{I fill in "Description" with "I wanted to add another name"}
    And %{I press "Create"}
end