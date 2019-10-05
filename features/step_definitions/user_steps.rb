DEFAULT_USER = "testuser"
DEFAULT_PASSWORD = "password"
NEW_USER = "newuser"

# GIVEN

Given /^I have no users$/ do
  User.delete_all
end

Given /I have an orphan account/ do
  user = FactoryBot.create(:user, login: 'orphan_account')
  user.activate
end

Given /the following activated users? exists?/ do |table|
  table.hashes.each do |hash|
    user = FactoryBot.create(:user, hash)
    user.activate
    user.pseuds.first.add_to_autocomplete
    step %{confirmation emails have been delivered}
  end
end

Given /the following users exist with BCrypt encrypted passwords/ do |table|
  table.hashes.each do |hash|
    user = FactoryBot.create(:user, hash)
    user.activate
    user.pseuds.first.add_to_autocomplete

    # salt = Authlogic::Random.friendly_token
    # same as
    salt = SecureRandom.urlsafe_base64(15)
    # encrypted_password = Authlogic::CryptoProviders::BCrypt.encrypt(hash[:password], salt)
    # same as
    encrypted_password = BCrypt::Password.create(
                           [hash[:password], salt].flatten.join,
                           cost: ArchiveConfig.BCRYPT_COST || 14)

    user.update(
      password_salt: salt,
      encrypted_password: encrypted_password
    )
  end
end

Given /the following users exist with SHA-512 encrypted passwords/ do |table|
  table.hashes.each do |hash|
    user = FactoryBot.create(:user, hash)
    user.activate
    user.pseuds.first.add_to_autocomplete

    # salt = Authlogic::Random.friendly_token
    # same as
    salt = SecureRandom.urlsafe_base64(15)
    # encrypted_password = Authlogic::CryptoProviders::Sha512.encrypt(hash[:password], salt)
    # same as
    encrypted_password = [hash[:password], salt].flatten.join
    20.times { encrypted_password = Digest::SHA512.hexdigest(encrypted_password) }

    user.update(
      password_salt: salt,
      encrypted_password: encrypted_password
    )
  end
end

Given /the following activated users with private work skins/ do |table|
  table.hashes.each do |hash|
    user = FactoryBot.create(:user, hash)
    user.activate
    FactoryBot.create(:private_work_skin, author: user, title: "#{user.login.titleize}'s Work Skin")
    step %{confirmation emails have been delivered}
  end
end

Given /the following activated tag wranglers? exists?/ do |table|
  table.hashes.each do |hash|
    user = FactoryBot.create(:user, hash)
    user.activate
    user.tag_wrangler = '1'
    user.pseuds.first.add_to_autocomplete
  end
end

Given /^the user "([^"]*)" exists and is activated$/ do |login|
  find_or_create_new_user(login, DEFAULT_PASSWORD)
  step %{confirmation emails have been delivered}
end

Given /^the user "([^"]*)" exists and is not activated$/ do |login|
  find_or_create_new_user(login, DEFAULT_PASSWORD, activate: false)
end

Given /^the user "([^"]*)" exists and has the role "([^"]*)"/ do |login, role|
  user = find_or_create_new_user(login, DEFAULT_PASSWORD)
  role = Role.find_or_create_by(name: role)
  user.roles = [role]
  user.save
end

Given /^I am logged in as "([^"]*)" with password "([^"]*)"$/ do |login, password|
  user = find_or_create_new_user(login, password)
  step("I am logged out")
  step %{I am on the homepage}
  find_link('login-dropdown').click

  fill_in "User name or email:", with: login
  fill_in "Password:", with: password
  check "Remember Me"
  click_button "Log In"
  step %{confirmation emails have been delivered}
end

Given /^I am logged in as "([^"]*)"$/ do |login|
  step(%{I am logged in as "#{login}" with password "#{DEFAULT_PASSWORD}"})
end

Given /^I am logged in$/ do
  step(%{I am logged in as "#{DEFAULT_USER}"})
end

Given /^I am logged in as a random user$/ do
  name = "testuser#{User.count + 1}"
  step(%{I am logged in as "#{name}" with password "#{DEFAULT_PASSWORD}"})
  step(%{confirmation emails have been delivered})
end

Given /^I am logged in as a banned user$/ do
  step(%{user "banned" is banned})
  step(%{I am logged in as "banned"})
end

Given /^user "([^"]*)" is banned$/ do |login|
  user = find_or_create_new_user(login, DEFAULT_PASSWORD)
  user.banned = true
  user.save
end

Given /^I am logged out$/ do
  visit destroy_user_session_path
  visit destroy_admin_session_path
end

Given /^I log out$/ do
  step(%{I follow "Log Out"})
end

Given /^"([^"]*)" has the pseud "([^"]*)"$/ do |username, pseud|
  step (%{I am logged in as "#{username}"})
  step(%{"#{username}" creates the pseud "#{pseud}"})
  step("I am logged out")
end

Given /^"([^"]*)" deletes their account/ do |username|
  visit user_path(username)
  step(%{I follow "Profile"})
  step(%{I follow "Delete My Account"})
end

Given /^I am a visitor$/ do
  step(%{I am logged out as an admin})
  step(%{I am logged out})
end

Given(/^I coauthored the work "(.*?)" as "(.*?)" with "(.*?)"$/) do |title, login, coauthor|
  step %{basic tags}
  author1 = User.find_by(login: login).default_pseud
  author1.user.preference.update(allow_cocreator: true)
  author2 = User.find_by(login: coauthor).default_pseud
  author2.user.preference.update(allow_cocreator: true)
  work = FactoryBot.create(:work, authors: [author1, author2], posted: true, title: title)
  work.creatorships.unapproved.each(&:accept!)
end

# WHEN

When /^I follow the link for "([^"]*)" first invite$/ do |login|
  user = User.find_by(login: login)
  invite = user.invitations.first
  step(%{I follow "#{invite.token}"})
end

When /^the user "([^\"]*)" has failed to log in (\d+) times$/ do |login, count|
  user = User.find_by(login: login)
  user.update(failed_attempts: count.to_i)
end

When /^"([^\"]*)" creates the default pseud "([^"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", with: newpseud
  check("pseud_is_default")
  click_button "Create"
end

When /^"([^"]*)" creates the pseud "([^"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", with: newpseud
  click_button "Create"
end

When /^I create the pseud "([^"]*)"$/ do |newpseud|
  visit new_user_pseud_path(User.current_user)
  fill_in "Name", with: newpseud
  click_button "Create"
end

When /^I fill in the sign up form with valid data$/ do
  step(%{I fill in "user_registration_login" with "#{NEW_USER}"})
  step(%{I fill in "user_registration_email" with "test@archiveofourown.org"})
  step(%{I fill in "user_registration_password" with "password1"})
  step(%{I fill in "user_registration_password_confirmation" with "password1"})
  step(%{I check "user_registration_age_over_13"})
  step(%{I check "user_registration_terms_of_service"})
end

When /^I try to delete my account as (.*)$/ do |login|
  step (%{I go to #{login}\'s user page})
  step (%{I follow "Profile"})
  step (%{I follow "Delete My Account"})
end

When /^I try to delete my account$/ do
  step (%{I try to delete my account as #{DEFAULT_USER}})
end

When /^I visit the change username page for (.*)$/ do |login|
  user = User.find_by(login: login)
  visit change_username_user_path(user)
end

When /^the user "(.*?)" accepts all (?:co-)?creator (?:invitations|invites)$/ do |login|
  # To make sure that we don't have caching issues with the byline:
  step %{I wait 1 second}
  user = User.find_by(login: login)
  user.creatorships.unapproved.each(&:accept!)
end

# THEN

Then /^I should get the error message for wrong username or password$/ do
  step(%{I should see "The password or user name you entered doesn't match our records. Please try again"})
end

Then /^I should get an activation email for "(.*?)"$/ do |login|
  step(%{1 email should be delivered})
  step(%{the email should contain "Welcome to the Archive of Our Own,"})
  step(%{the email should contain "#{login}"})
  step(%{the email should contain "activate your account"})
end

Then /^I should get a new user activation email$/ do
  step(%{I should get an activation email for "#{NEW_USER}"})
end

Then /^a user account should exist for "(.*?)"$/ do |login|
   user = User.find_by(login: login)
   assert !user.blank?
end

Then /^a user account should not exist for "(.*)"$/ do |login|
  user = User.find_by(login: login)
  assert user.blank?
end

Then /^a new user account should exist$/ do
  step %{a user account should exist for "#{NEW_USER}"}
end

Then /^I should be logged out$/ do
  expect(User.current_user).to be(nil)
end

def get_work_name(age, classname, name)
  klass = classname.classify.constantize
  owner = (classname == "user") ? klass.find_by(login: name) : klass.find_by(name: name)
  if age == "most recent"
    owner.works.order("revised_at DESC").first.title
  elsif age == "oldest"
    owner.works.order("revised_at DESC").last.title
  end
end

def get_series_name(age, classname, name)
  klass = classname.classify.constantize
  owner = (classname == "user") ? klass.find_by(login: name) : klass.find_by(name: name)
  if age == "most recent"
    owner.series.order("updated_at DESC").first.title
  elsif age == "oldest"
    owner.series.order("updated_at DESC").last.title
  end
end

Then /^I should see the (most recent|oldest) (work|series) for (pseud|user) "([^"]*)"/ do |age, type, classname, name|
  title = (type == "work" ? get_work_name(age, classname, name) : get_series_name(age, classname, name))
  step %{I should see "#{title}"}
end

Then /^I should not see the (most recent|oldest) (work|series) for (pseud|user) "([^"]*)"/ do |age, type, classname, name|
  title = (type == "work" ? get_work_name(age, classname, name) : get_series_name(age, classname, name))
  step %{I should not see "#{title}"}
end

When /^I change my username to "([^"]*)"/ do |new_name|
  visit change_username_user_path(User.current_user)
  fill_in("New user name", with: new_name)
  fill_in("Password", with: "password")
  click_button("Change User Name")
  step %{I should get confirmation that I changed my username}
end

Then /^I should get confirmation that I changed my username$/ do
  step(%{I should see "Your user name has been successfully updated."})
end

Then /^the user "([^"]*)" should be activated$/ do |login|
  user = User.find_by(login: login)
  assert user.active?
end

Then /^I should see the current user's preferences in the console$/ do
  puts User.current_user.preference.inspect
end
