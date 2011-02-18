Given /^I have no users$/ do
  User.delete_all
end

Given /I have an orphan account/ do
  user = Factory.create(:user, :login => 'orphan_account')
  user.activate
end

Given /the following activated users? exists?/ do |table|
  table.hashes.each do |hash|
    user = Factory.create(:user, hash)
    user.activate
  end
end

Given /the following activated tag wranglers? exists?/ do |table|
  table.hashes.each do |hash|
    user = Factory.create(:user, hash)
    user.activate
    user.tag_wrangler = '1'
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  user = User.find_by_login(login)
  if user.blank?
    user = Factory.create(:user, {:login => login, :password => password})
    user.activate
  else
    user.password = password
    user.password_confirmation = password
    user.save
  end
  visit login_path
  fill_in "User name", :with => login
  fill_in "Password", :with => password
  check "Remember me"
  click_button "Log in"
  assert UserSession.find
end

When /^I fill in "([^\"]*)"'s temporary password$/ do |login|
  # " '
  user = User.find_by_login(login)
  fill_in "Password", :with => user.activation_code
end


Given /^I am logged in as a random user$/ do
  name = "testuser#{User.count + 1}"
  user = Factory.create(:user, :login => name, :password => "password")
  user.activate
  visit login_path
  fill_in "User name", :with => name
  fill_in "Password", :with => "password"
  check "Remember me"
  click_button "Log in"
  assert UserSession.find
end

Given /^I am logged out$/ do
  visit logout_path
  assert !UserSession.find
end

When /^"([^\"]*)" creates the pseud "([^\"]*)"$/ do |username, newpseud|
  visit user_pseuds_path(username)
  click_link("New Pseud")
  fill_in "Name", :with => newpseud
  click_button "Create"
end

When /^"([^\"]*)" creates the default pseud "([^\"]*)"$/ do |username, newpseud|
  visit user_pseuds_path(username)
  click_link("New Pseud")
  fill_in "Name", :with => newpseud
  # TODO: this isn't currently working
  check "Is default"
  click_button "Create"
end


Given /^"([^\"]*)" deletes their account/ do |username|
  visit user_path(username)
  Given %{I follow "Profile"}
  Given %{I follow "Delete My Account"}
end

Given /^I am a visitor$/ do
  Given %{I am logged out}
end
###########################################################
def user(attributes = {})
  @user ||= Factory.create(:user, attributes)
  @user.activate
  @user
end
def login (user)
  visit login_path
  fill_in "User name", :with => user.login
  fill_in "Password", :with => user.password
  click_button "Log in"
end
### Given
Given /^I am not logged in$/ do
  visit logout_path
end
Given /^I am logged in$/ do
  login(user)
end
Given /^I am logged in with username "([^"]*)"$/ do |username|
  login(user(:login => username))
end
Given /^A user "([^"]*)" exists$/ do |username|
  Factory.create(:user, :login => username)
end
### When
When /^I delete my account(?: and ([^"]*) my ([^"]*))?$/ do |method, items|
  visit user_profile_path(user)
  click_link "Delete My Account"
  case method
    when "delete"
      choose "Delete completely"
      click_button "Save"
    when "orphan"
      choose "Change my pseud to 'orphan' and attach to the orphan account"
      click_button "Save"
    end
end
When /^I change my username to "([^"]*)"(?: using password "([^"]*)")?$/ do |new_username, password|
  password ||= user.password
  visit change_username_user_path(user)
  fill_in "New User Name", :with => new_username
  fill_in "Re-enter Your Password", :with => password
  click_button "Change"
end
When /^I visit my dashboard$/ do
  visit user_path(user)
end
### Then
Then /^I cannot log in$/ do
  login(user)
  page.should have_content("We couldn't find that user")
end
Then /^I should have username "([^"]*)"$/ do |username|
  user.reload.login.should == username
end
Then /^I should not have username "([^"]*)"$/ do |username|
  user.reload.login.should_not == username
end
Then /^I should not see any fandoms or works$/ do
  page.should have_no_content("Fandoms")
  page.should have_no_content("Recent works")
end
Then /^I should see my work "([^"]*)"(?: with fandom "([^"]*)")?$/ do |work, fandom|
  with_scope('#user-works') do
    page.should have_content(work)
    page.should have_content(fandom) unless fandom.nil?
  end
end
Then /^I should see the fandom "([^"]*)"$/ do |fandom|
  with_scope('#user-fandoms') do
    page.should have_content(fandom)
  end
end
Then /^I should not see the fandom "([^"]*)"$/ do |fandom|
  with_scope('#user-fandoms') do
    page.should_not have_content(fandom)
  end
end

