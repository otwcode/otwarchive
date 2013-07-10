Given /^I want to edit my profile$/ do
  visit user_profile_path(User.current_user)
  click_link("Edit My Profile")
  step %{I should see "Edit My Profile"}
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
  click_link("Email")
  fill_in("New Email", :with => "valid2@archiveofourown.org")
  fill_in("Confirm New Email", :with => "valid2@archiveofourown.org")
  fill_in("Password", :with => "passw")
  click_button("Change Email")
end


When /^I change my email$/ do
  click_link("Email")
  fill_in("New Email", :with => "valid2@archiveofourown.org")
  fill_in("Confirm New Email", :with => "valid2@archiveofourown.org")
  fill_in("Password", :with => "password")
  click_button("Change Email")
end


When /^I view my profile$/ do
  visit user_path(User.current_user)
  step %{I should see "Dashboard"}
  click_link("Profile")
end

		
When /^I enter an invalid email$/ do
  click_link("Email")
  fill_in("New Email", :with => "bob.bob.bob")
  fill_in("Confirm New Email", :with => "bob.bob.bob")
  fill_in("Password", :with => "password")
  click_button("Change Email")
end


When /^I enter a duplicate email$/ do
  user = FactoryGirl.create(:user, :login => "testuser2", :password => "password", :email => "foo@ao3.org")
  user.activate
  click_link("Email")
  fill_in("New Email", :with => "foo@ao3.org")
  fill_in("Confirm New Email", :with => "foo@ao3.org")
  fill_in("Password", :with => "password")
  click_button("Change Email")
end


When /^I enter a birthdate that shows I am under age$/ do
  time = Time.new
  under_age_year = time.year - 13
  select("#{under_age_year}", :from => "profile_attributes[date_of_birth(1i)]")
  select("December", :from => "profile_attributes[date_of_birth(2i)]")
  select("31", :from => "profile_attributes[date_of_birth(3i)]")
  click_button("Update")
end
	

When /^I change my preferences to display my date of birth$/ do
  click_link("Preferences")
  check ("Show my date of birth to other people.")
  click_button("Update")
  visit user_path(User.current_user)
  click_link("Profile")
end


When /^I change my preferences to display my email address$/ do
  click_link("Preferences")
  check ("Show my email address to other people.")
  click_button("Update")
  visit user_path(User.current_user)
  click_link("Profile")
end


When /^I fill in my date of birth$/ do
  select("1980", :from => "profile_attributes[date_of_birth(1i)]")
  select("November", :from => "profile_attributes[date_of_birth(2i)]")
  select("30", :from => "profile_attributes[date_of_birth(3i)]")
  click_button("Update")
end


When /^I make a mistake typing my old password$/ do
  click_link("Password")
  fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass1")
  fill_in("Old Password", :with => "wrong")
  click_button("Change Password")
end


When /^I make a typing mistake confirming my new password$/ do
  click_link("Password")
  fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass2")
  fill_in("Old Password", :with => "password")
  click_button("Change Password")
end


When /^I change my password$/ do
  click_link("Password")
  fill_in("New Password", :with => "newpass1")
  fill_in("Confirm New Password", :with => "newpass1")
  fill_in("Old Password", :with => "password")
  click_button("Change Password")
end
