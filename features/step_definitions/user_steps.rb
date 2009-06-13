Given /^the following (.+) records?$/ do |factory, table|
  table.hashes.each do |hash|
    user = Factory(factory, hash)
    user.activate
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  unless login.blank?
    visit login_url
    fill_in "User name", :with => login
    fill_in "Password", :with => password
    check "Remember me"
    click_button "Login"
  end
end

Given /^I am logged in as a random user$/ do
  user =  Factory.create(:user)
  user.activate
  visit login_url
  fill_in "User name", :with => user.login
  fill_in "Password", :with => "password"
  check "Remember me"
  click_button "Login"  
end

Given /^I create a user named "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  user = Factory.create(:user, :login => login, :password => password)
  user.activate
end

Given /^I create a user named "([^\"]*)" with email "([^\"]*)"$/ do |login, email|
  user = Factory.create(:user, :login => login, :email => email)
  user.activate
end

When /^I visit user page for "([^\"]*)"$/ do |login|
  user = User.find_by_login!(login)
  visit user_url(user)
end