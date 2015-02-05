default_settings = {
  :invite_from_queue_enabled => ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
  :invite_from_queue_number => ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
  :invite_from_queue_frequency => ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
  :account_creation_enabled => true,
  :creation_requires_invite => true,
  :request_invite_enabled => true,
  :days_to_purge_unactivated => ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED
}

def update_settings(settings)
  admin_settings = AdminSetting.first_or_create
  admin_settings.update_attributes(settings)
  admin_settings.save(:validate => false)
end

### GIVEN

Given /^I have an AdminSetting$/ do
  unless AdminSetting.first
    settings = AdminSetting.new(default_settings)
    settings.save(:validate => false)
  end
end

Given /^the following admin settings are configured:$/ do |table|
  settings = default_settings.merge(table.rows_hash.symbolize_keys)
  update_settings settings
end

Given /^default admin settings$/ do
  update_settings settings = {}
end

Given /the following admins? exists?/ do |table|
  table.hashes.each do |hash|
    admin = FactoryGirl.create(:admin, hash)
  end
end

Given /^I am logged in as an admin$/ do
  step("I am logged out")
  admin = Admin.find_by_login("testadmin")
  if admin.blank?
    admin = FactoryGirl.create(:admin, :login => "testadmin", :password => "testadmin", :email => "testadmin@example.org")
  end
  visit admin_login_path
  fill_in "Admin user name", :with => "testadmin"
  fill_in "Admin password", :with => "testadmin"
  click_button "Log in as admin"
  step("I should see \"Successfully logged in\"")
end

Given /^I am logged out as an admin$/ do
  visit admin_logout_path
  assert !AdminSession.find
end

Given /^basic languages$/ do
  Language.default
  Language.find_or_create_by_short_and_name("DE", "Deutsch")
end

Given /^advanced languages$/ do
  Language.find_or_create_by_short_and_name("FR", "Francais")
end

Given /^guest downloading is off$/ do
  step("I am logged in as an admin")
  visit(admin_settings_path)
  check("Turn off downloading for guests")
  click_button("Update")
end

Given /^guest downloading is on$/ do
  step("I am logged in as an admin")
  visit(admin_settings_path)
  uncheck("Turn off downloading for guests")
  click_button("Update")
end

Given /^tag wrangling is off$/ do
  step("I am logged in as an admin")
  visit(admin_settings_path)
  step("I check \"Turn off tag wrangling for non-admins\"")
  step("I press \"Update\"")
  step("I am logged out as an admin")
end

Given /^tag wrangling is on$/ do
  step("I am logged in as an admin")
  visit(admin_settings_path)
  step("I uncheck \"Turn off tag wrangling for non-admins\"")
  step("I press \"Update\"")
  step("I am logged out as an admin")
end

Given /^I have posted a FAQ$/ do
  step("I am logged in as an admin")
  step(%{I make a 1st FAQ post})
end

Given /^I have posted known issues$/ do
  step(%{I am logged in as an admin})
    step(%{I follow "Admin Posts"})
    step(%{I follow "Known Issues" within "#main"})
    step(%{I follow "make a new known issues post"})
    step(%{I fill in "known_issue_title" with "First known problem"})
    step(%{I fill in "content" with "This is a bit of a problem"})
    step(%{I press "Post"})
end

Given /^I have posted an admin post$/ do
  step("I am logged in as an admin")
    step("I make an admin post")
    step("I am logged out as an admin")
end

### WHEN

When /^I turn off guest downloading$/ do
  step("I am logged in as an admin")
  visit(admin_settings_path)
  step("I check \"Turn off downloading for guests\"")
  step("I press \"Update\"")
end

When /^I make an admin post$/ do
  visit new_admin_post_path
  fill_in("admin_post_title", :with => "Default Admin Post")
  fill_in("content", :with => "Content of the admin post.")
  click_button("Post")
end

When /^I make a(?: (\d+)(?:st|nd|rd|th)?)? FAQ post$/ do |n|
  n ||= 1
  visit new_archive_faq_path
  fill_in("Question*", :with => "Number #{n} Question.")
  fill_in("Answer*", :with => "Number #{n} posted FAQ, this is.")
  fill_in("Category name*", :with => "Number #{n} FAQ")
  fill_in("Anchor name*", :with => "Number#{n}anchor")
  click_button("Post")
end

When /^there are (\d+) Archive FAQs$/ do |n|
  (1..n.to_i).each do |i|
    step(%{I make a #{i} FAQ post})
  end
end

When /^I make a(?: (\d+)(?:st|nd|rd|th)?)? Admin Post$/ do |n|
  n ||= 1
  visit new_admin_post_path
  fill_in("admin_post_title", :with => "Amazing News #{n}")
  fill_in("content", :with => "This is the content for the #{n} Admin Post")
  click_button("Post")
end

When /^there are (\d+) Admin Posts$/ do |n|
  (1..n.to_i).each do |i|
    step(%{I make a #{i} Admin Post})
  end
end

When /^(\d+) Archive FAQs? exists?$/ do |n|
  (1..n.to_i).each do |i|
    FactoryGirl.create(:archive_faq, id: i)
  end
end

When /^(\d+) Admin Posts? exists?$/ do |n|
  (1..n.to_i).each do |i|
    FactoryGirl.create(:admin_post, id: i)
  end
end

When /^the invite_from_queue_at is yesterday$/ do
  AdminSetting.first.update_attribute(:invite_from_queue_at, Time.now - 1.day)
end

When /^the check_queue rake task is run$/ do
  AdminSetting.check_queue
end

When /^I edit known issues$/ do
  step(%{I am logged in as an admin})
    step( %{I follow "Admin Posts"})
    step(%{I follow "Known Issues" within "#main"})
    step(%{I follow "Edit"})
    step(%{I fill in "known_issue_title" with "More known problems"})
    step(%{I fill in "content" with "This is a bit of a problem, and this is too"})
    step(%{I press "Post"})
end

Given(/^the following language exists$/) do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:language, hash)
  end
end

### THEN

When (/^I make a translation of an admin post$/) do
  visit new_admin_post_path
  fill_in("admin_post_title", :with => "Deutsch Ankuendigung")
  fill_in("content", :with => "Deutsch Woerter")
  step(%{I select "Deutsch" from "Choose a language"})
  fill_in("admin_post_translated_post_id", :with => AdminPost.find_by_title("Default Admin Post").id)
  click_button("Post")
end

Then (/^I should see a translated admin post$/) do
  step(%{I go to the admin-posts page})
  step(%{I should see "Default Admin Post"})
    step(%{I should not see "Deutsch Ankuendigung"})
  step(%{I follow "Default Admin Post"})
  step(%{I should see "Translations: Deutsch Deutsch Ankuendigung"})
  step(%{I follow "Deutsch Ankuendigung"})
  step(%{I should see "Deutsch Woerter"})
end

Then (/^I should not see a translated admin post$/) do
  step(%{I go to the admin-posts page})
  step(%{I should see "Default Admin Post"})
  step(%{I should see "Deutsch Ankuendigung"})
  step(%{I follow "Default Admin Post"})
  step(%{I should not see "Translations: Deutsch Deutsch Ankuendigung"})
end

Then /^logged out users should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am logged out})
  step(%{I should not see the hidden work "#{work}" by "#{user}"})
end

Then /^logged in users should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am logged in as a random user})
  step(%{I should not see the hidden work "#{work}" by "#{user}"})
end

Then /^I should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am on #{user}'s works page})
  step(%{I should not see "#{work}"})
  step(%{I view the work "#{work}"})
  step(%{I should see "Sorry, you don't have permission to access the page you were trying to reach."})
end

Then /^"([^\"]*)" should see their work "([^\"]*)" is hidden?/ do |user, work|
  step(%{I am logged in as "#{user}"})
  step(%{I am on my works page})
  step(%{I should not see "#{work}"})
  step(%{I view the work "#{work}"})
  step(%{I should see the image "title" text "Hidden by Administrator"})
end

Then /^logged out users should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am logged out})
  step(%{I should see the unhidden work "#{work}" by "#{user}"})
end

Then /^logged in users should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am logged in as a random user})
  step(%{I should see the unhidden work "#{work}" by "#{user}"})
end

Then /^I should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step(%{I am on #{user}'s works page})
  step(%{I should see "#{work}"})
  step(%{I view the work "#{work}"})
  step(%{I should see "#{work}"})
end