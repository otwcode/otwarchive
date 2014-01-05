DEFAULT_USER = "testuser"
DEFAULT_PASSWORD = "password"
NEW_USER = "newuser"

# GIVEN

Given /^I have no users$/ do
  User.delete_all
end

Given /I have an orphan account/ do
  user = FactoryGirl.create(:user, :login => 'orphan_account')
  user.activate
end

Given /the following activated users? exists?/ do |table|
  table.hashes.each do |hash|
    user = FactoryGirl.create(:user, hash)
    user.activate
  end
end

Given /the following activated tag wranglers? exists?/ do |table|
  table.hashes.each do |hash|
    user = FactoryGirl.create(:user, hash)
    user.activate
    user.tag_wrangler = '1'
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  step("I am logged out")
  user = User.find_by_login(login)
  if user.blank?
    user = FactoryGirl.create(:user, {:login => login, :password => password})
    user.activate
  else
    user.password = password
    user.password_confirmation = password
    user.save
  end
  visit login_path
  fill_in "User name", :with => login
  fill_in "Password", :with => password
  check "Remember Me"
  click_button "Log In"
  assert UserSession.find
end

Given /^I am logged in as "([^\"]*)"$/ do |login|
  step(%{I am logged in as "#{login}" with password "#{DEFAULT_PASSWORD}"})
end

Given /^I am logged in$/ do
  step(%{I am logged in as "#{DEFAULT_USER}"})
end

Given /^I am logged in as a random user$/ do
  step("I am logged out")
  name = "testuser#{User.count + 1}"
  user = FactoryGirl.create(:user, :login => name, :password => DEFAULT_PASSWORD)
  user.activate
  visit login_path
  fill_in "User name", :with => name
  fill_in "Password", :with => DEFAULT_PASSWORD
  check "Remember me"
  click_button "Log In"
  assert UserSession.find
end

Given /^I am logged out$/ do
  visit logout_path
  assert !UserSession.find
  visit admin_logout_path
  assert !AdminSession.find
end

Given /^I log out$/ do
  step(%{I follow "Log Out"})
end

Given /^"([^\"]*)" has the pseud "([^\"]*)"$/ do |username, pseud|
  step (%{I am logged in as "#{username}"})
  step(%{"#{username}" creates the pseud "#{pseud}"})
  step("I am logged out")
end

Given /^"([^\"]*)" deletes their account/ do |username|
  visit user_path(username)
  step(%{I follow "Profile"})
  step(%{I follow "Delete My Account"})
end

Given /^I am a visitor$/ do
  step(%{I am logged out})
end

Given /^I view the people page$/ do
  visit people_path
end

Given(/^I have coauthored a work as "(.*?)" with "(.*?)"$/) do |login, coauthor|
  author1 = FactoryGirl.create(:pseud, :user => User.find_by_login(login))
  author2 = FactoryGirl.create(:pseud, :user => User.find_by_login(coauthor))
  work = FactoryGirl.create(:work, :authors => [author1, author2], :posted => true)
end

# WHEN

When /^"([^\"]*)" creates the default pseud "([^\"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", :with => newpseud
  check("pseud_is_default")
  click_button "Create"
end

When /^I fill in "([^\"]*)"'s temporary password$/ do |login|
  # " '
  user = User.find_by_login(login)
  fill_in "Password", :with => user.activation_code
end

When /^"([^\"]*)" creates the pseud "([^\"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", :with => newpseud
  click_button "Create"
end

When /^I create the pseud "([^\"]*)"$/ do |newpseud|
  visit new_user_pseud_path(User.current_user)
  fill_in "Name", :with => newpseud
  click_button "Create"
end

When(/^I fill in the sign up form with valid data$/) do
  step(%{I fill in "user_login" with "#{NEW_USER}"})
  step(%{I fill in "user_email" with "test@archiveofourown.org"})
  step(%{I fill in "user_password" with "password1"})
  step(%{I fill in "user_password_confirmation" with "password1"})
  step(%{I check "user_age_over_13"})
  step(%{I check "user_terms_of_service"})
end

When(/^I try to delete my account as (.*)$/) do |login|
  step (%{I go to #{login}\'s user page})
  step (%{I follow "Profile"})
  step (%{I follow "Delete My Account"})
end

When(/^I try to delete my account$/) do
  step (%{I try to delete my account as #{DEFAULT_USER}})
end

# THEN

Then /^I should get the error message for wrong username or password$/ do
  step(%{I should see "The password or user name you entered doesn't match our records. Please try again"})
end

Then (/^I should get an activation email for "(.*?)"$/) do |login|
  step(%{1 email should be delivered})
  step(%{the email should contain "Welcome to the Archive of Our Own,"})
  step(%{the email should contain "#{login}"})
  step(%{the email should contain "Please activate your account"})
end

Then (/^I should get a new user activation email$/) do
  step(%{I should get an activation email for "#{NEW_USER}"})
end

Then(/^a user account should exist for "(.*?)"$/) do |login|
   user = User.find_by_login(login)
   assert !user.blank?
end

Then(/^a user account should not exist for "(.*)"$/) do |login|
  user = User.find_by_login(login)
  assert user.blank?
end

Then(/^a new user account should exist$/) do
  step(%{a user account should exist for "#{NEW_USER}"})
end

Then(/^I should be logged out$/) do
  assert !UserSession.find
end

def get_work_name(age, classname, name)
  klass = classname.classify.constantize
  owner = (classname == "user") ? klass.find_by_login(name) : klass.find_by_name(name)
  if age == "most recent"
    owner.works.order("revised_at DESC").first.title
  elsif age == "oldest"
    owner.works.order("revised_at DESC").last.title
  end
end

def get_series_name(age, classname, name)
  klass = classname.classify.constantize
  owner = (classname == "user") ? klass.find_by_login(name) : klass.find_by_name(name)
  if age == "most recent"
    owner.series.order("updated_at DESC").first.title
  elsif age == "oldest"
    owner.series.order("updated_at DESC").last.title
  end
end
  
Then /^I should see the (most recent|oldest) (work|series) for (pseud|user) "([^\"]*)"/ do |age, type, classname, name|
  title = (type == "work" ? get_work_name(age, classname, name) : get_series_name(age, classname, name))
  step %{I should see "#{title}"}
end

Then /^I should not see the (most recent|oldest) (work|series) for (pseud|user) "([^\"]*)"/ do |age, type, classname, name|
  title = (type == "work" ? get_work_name(age, classname, name) : get_series_name(age, classname, name))
  step %{I should not see "#{title}"}
end
