Given /^I have no users$/ do
  User.delete_all
end

Given /the following activated users? exists?/ do |table|
  table.hashes.each do |hash|
    user = Factory.create(:user, hash)
    user.activate
  end
end

Given /the following admins? exists?/ do |table|
  table.hashes.each do |hash|
    admin = Factory.create(:admin, hash)
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  visit login_path
  fill_in "User name", :with => login
  fill_in "Password", :with => password
  check "Remember me"
  click_button "Login"
end

Given /^I am logged in as a random user$/ do 
  user = Factory.create(:user, :login => "testuser", :password => "password")
  user.activate
  visit login_path
  fill_in "User name", :with => "testuser"
  fill_in "Password", :with => "password"
  check "Remember me"
  click_button "Login"
end
