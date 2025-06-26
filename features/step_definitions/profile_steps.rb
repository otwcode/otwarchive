Given /^I want to edit my profile$/ do
  step "I view my profile"
  click_link("Edit My Profile")
  step %{I should see "Edit My Profile"}
end


When /^I fill in the details of my profile$/ do
  fill_in("Title", with: "Test title thingy")
  fill_in("Location", with: "Alpha Centauri")
  fill_in("About Me", with: "This is some text about me.")
  click_button("Update")
end


When /^I change the details in my profile$/ do
  fill_in("Title", with: "Alternative title thingy")
  fill_in("Location", with: "Beta Centauri")
  fill_in("About Me", with: "This is some different text about me.")
  click_button("Update")
end


When /^I remove details from my profile$/ do
  fill_in("Title", with: "")
  fill_in("Location", with: "")
  fill_in("About Me", with: "")
  click_button("Update")
end

When "the email address change confirmation period is set to {int} days" do |amount|
  allow(Devise).to receive(:confirm_within).and_return(amount.days)
end

When "I start to change my email to {string}" do |email|
  step %{I fill in "New email" with "#{email}"}
  step %{I fill in "Enter new email again" with "#{email}"}
  step %{I fill in "Password" with "password"}
  step %{I press "Confirm New Email"}
end

When "I confirm my email change request to {string}" do |email|
  step %{I should see "Are you sure you want to change your email address to #{email}?"}
  step %{I press "Yes, Change Email"}
end

When "I request to change my email to {string}" do |email|
  step %{I start to change my email to "#{email}"}
  step %{I confirm my email change request to "#{email}"}
end

When "I change my email to {string}" do |email|
  step %{I follow "My Preferences"}
  step %{I follow "Change Email"}
  step %{I request to change my email to "#{email}"}
  step %{1 email should be delivered to "#{email}"}
  step %{I follow "confirm your email change" in the email}
  step %{I should see "Your email has been successfully updated."}
end

When /^I view my profile$/ do
  step %{I follow "My Dashboard"}
  step %{I should see "Dashboard"}
  click_link("Profile")
end

When /^I enter a birthdate that shows I am under age$/ do
  date = 13.years.ago + 1.day
  select(date.year, from: "profile_attributes[date_of_birth(1i)]")
  select(date.strftime("%B"), from: "profile_attributes[date_of_birth(2i)]")
  select(date.day, from: "profile_attributes[date_of_birth(3i)]")
  click_button("Update")
end


When /^I change my preferences to display my date of birth$/ do
  click_link("Preferences")
  check ("Show my date of birth to other people.")
  click_button("Update")
  step %{I follow "My Dashboard"}
  click_link("Profile")
end


When /^I change my preferences to display my email address$/ do
  click_link("Preferences")
  check ("Show my email address to other people.")
  click_button("Update")
  step %{I follow "My Dashboard"}
  click_link("Profile")
end


When /^I fill in my date of birth$/ do
  select("1980", from: "profile_attributes[date_of_birth(1i)]")
  select("November", from: "profile_attributes[date_of_birth(2i)]")
  select("30", from: "profile_attributes[date_of_birth(3i)]")
  click_button("Update")
end


When /^I make a mistake typing my old password$/ do
  click_link("Password")
  fill_in("password", with: "newpass1")
  fill_in("password_confirmation", with: "newpass1")
  fill_in("password_check", with: "wrong")
  click_button("Change Password")
end


When /^I make a typing mistake confirming my new password$/ do
  click_link("Password")
  fill_in("password", with: "newpass1")
  fill_in("password_confirmation", with: "newpass2")
  fill_in("password_check", with: "password")
  click_button("Change Password")
end


When /^I change my password$/ do
  click_link("Password")
  fill_in("password", with: "newpass1")
  fill_in("password_confirmation", with: "newpass1")
  fill_in("password_check", with: "password")
  click_button("Change Password")
end
