default_settings = {
  invite_from_queue_enabled: ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
  invite_from_queue_number: ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
  invite_from_queue_frequency: ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
  account_creation_enabled: true,
  creation_requires_invite: true,
  request_invite_enabled: true,
  days_to_purge_unactivated: ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED
}

def update_settings(settings)
  admin_settings = AdminSetting.first_or_create
  admin_settings.update_attributes(settings)
  admin_settings.save(validate: false)
end

### GIVEN

Given /^I have an AdminSetting$/ do
  unless AdminSetting.first
    settings = AdminSetting.new(default_settings)
    settings.save(validate: false)
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
    FactoryBot.create(:admin, hash)
  end
end

Given /^I am logged in as admin with role "([^\"]*)"$/ do |role|
  step("I am logged in as an admin")
  admin = Admin.find_by(login: "testadmin")
  admin.roles << role
  admin.save!
end

Given /^I am logged in as an admin$/ do
  step("I have an AdminSetting")
  step("I am logged out")
  admin = Admin.find_by(login: "testadmin")
  if admin.blank?
    FactoryBot.create(:admin, login: "testadmin", password: "testadmin", email: "testadmin@example.org")
  end
  visit new_admin_session_path
  fill_in "Admin user name", with: "testadmin"
  fill_in "Admin password", with: "testadmin"
  click_button "Log in as admin"
  step(%{I should see "Successfully logged in"})
end

Given /^I am logged in as superadmin$/ do
  step("I have an AdminSetting")
  step("I am logged out")
  admin = Admin.find_by(login: "superadmin")
  if admin.blank?
    FactoryBot.create(:superadmin)
  end
  visit new_admin_session_path
  fill_in "Admin user name", with: "superadmin"
  fill_in "Admin password", with: "IHaveThePower"
  click_button "Log in as admin"
  step(%{I should see "Successfully logged in"})
end

Given /^I am logged out as an admin$/ do
  visit destroy_admin_session_path
end

Given /^basic languages$/ do
  Language.default
  german = Language.find_or_create_by(short: "DE", name: "Deutsch", support_available: true, abuse_support_available: true)
  de = Locale.new
  de.iso = 'de'
  de.name = 'Deutsch'
  de.language_id = german.id
  de.save!
end

Given /^advanced languages$/ do
  Language.find_or_create_by(short: "FR", name: "Francais")
end

Given /^downloads are off$/ do
  step("I am logged in as superadmin")
  visit(admin_settings_path)
  uncheck("Allow downloads")
  click_button("Update")
end

Given /^tag wrangling is off$/ do
  step("I am logged in as superadmin")
  visit(admin_settings_path)
  step(%{I check "Turn off tag wrangling for non-admins"})
  step(%{I press "Update"})  
  step("I am logged out as an admin")
end

Given /^tag wrangling is on$/ do
  step("I am logged in as superadmin")
  visit(admin_settings_path)
  step(%{I uncheck "Turn off tag wrangling for non-admins"})
  step(%{I press "Update"})
  step("I am logged out as an admin")
end

Given /^the support form is disabled and its text field set to "Please don't contact us"$/ do
  step("I am logged in as superadmin")
  visit(admin_settings_path)
  check("Turn off support form")
  fill_in(:admin_setting_disabled_support_form_text, with: "Please don't contact us")
  click_button("Update")
end

Given /^the support form is enabled$/ do
  step("I am logged in as superadmin")
  visit(admin_settings_path)
  uncheck("Turn off support form")
  click_button("Update")
end

Given /^I have posted a FAQ$/ do
  step("I am logged in as an admin")
  step %{I make a 1st FAQ post}
end

Given /^I have posted known issues$/ do
  step %{I am logged in as an admin}
  step %{I follow "Admin Posts"}
  step %{I follow "Known Issues" within "#header"}
  step %{I follow "make a new known issues post"}
  step %{I fill in "known_issue_title" with "First known problem"}
  step %{I fill in "content" with "This is a bit of a problem"}
  step %{I press "Post"}
end

Given /^I have posted an admin post$/ do
  step(%{I am logged in as admin with role "communications"})
  step("I make an admin post")
  step("I am logged out as an admin")
end

Given /^the fannish next of kin "([^\"]*)" for the user "([^\"]*)"$/ do |kin, user|
  step %{the user "#{kin}" exists and is activated}
  step %{the user "#{user}" exists and is activated}
  step %{I am logged in as superadmin}
  step %{I go to the abuse administration page for "#{user}"}
  fill_in("Fannish next of kin's username", with: "#{kin}")
  fill_in("Fannish next of kin's email", with: "testing@foo.com")
  click_button("Update")
end

Given /^the user "([^\"]*)" is suspended$/ do |user|
  step %{the user "#{user}" exists and is activated}
  step %{I am logged in as superadmin}
  step %{I go to the abuse administration page for "#{user}"}
  choose("admin_action_suspend")
  fill_in("suspend_days", with: 30)
  fill_in("Notes", with: "Why they are suspended")
  click_button("Update")
end

Given /^the user "([^\"]*)" is banned$/ do |user|
  step %{the user "#{user}" exists and is activated}
  step %{I am logged in as superadmin}
  step %{I go to the abuse administration page for "#{user}"}
  choose("admin_action_ban")
  fill_in("Notes", with: "Why they are banned")
  click_button("Update")
end

Then /^the user "([^\"]*)" should be permanently banned$/ do |user|
  u = User.find_by(login: user)
  assert u.banned?
end

Given /^I have posted an admin post without paragraphs$/ do
  step(%{I am logged in as admin with role "communications"})
  step("I make an admin post without paragraphs")
  step("I am logged out as an admin")
end

Given /^I have posted an admin post with tags$/ do
  step(%{I am logged in as admin with role "communications"})
  visit new_admin_post_path
  fill_in("admin_post_title", with: "Default Admin Post")
  fill_in("content", with: "Content of the admin post.")
  fill_in("admin_post_tag_list", with: "quotes, futurama")
  click_button("Post")
end

Given(/^the following language exists$/) do |table|
  table.hashes.each do |hash|
    FactoryBot.create(:language, hash)
  end
end

### WHEN

When /^I visit the last activities item$/ do
  visit("/admin/activities/#{AdminActivity.last.id}")
end

When /^I fill in "([^"]*)" with "([^"]*)'s" invite code$/  do |field, login|
  user = User.find_by(login: login)
  token = user.invitations.first.token
  fill_in(field, with: token)
end

When /^I make an admin post$/ do
  visit new_admin_post_path
  fill_in("admin_post_title", with: "Default Admin Post")
  fill_in("content", with: "Content of the admin post.")
  click_button("Post")
end

When /^I make an admin post without paragraphs$/ do
  visit new_admin_post_path
  fill_in("admin_post_title", with: "Admin Post Without Paragraphs")
  fill_in("content", with: "<ul><li>This post</li><li>is just</li><li>a list</li></ul>")
  click_button("Post")
end

When /^I make a(?: (\d+)(?:st|nd|rd|th)?)? FAQ post$/ do |n|
  n ||= 1
  visit new_archive_faq_path
  fill_in("Question*", with: "Number #{n} Question.")
  fill_in("Answer*", with: "Number #{n} posted FAQ, this is.")
  fill_in("Category name*", with: "Number #{n} FAQ")
  fill_in("Anchor name*", with: "Number#{n}anchor")
  click_button("Post")
end

When /^I make a multi-question FAQ post$/ do
  visit new_archive_faq_path
  fill_in("Question*", with: "Number 1 Question.")
  fill_in("Answer*", with: "Number 1 posted FAQ, this is.")
  fill_in("Category name*", with: "Standard FAQ Category")
  fill_in("Anchor name*", with: "Number1anchor")
  click_button("Post")
  step %{I follow "Edit"}
  step %{I fill in "Questions:" with "3"}
  step %{I press "Update Form"}
  fill_in("archive_faq_questions_attributes_1_question", with: "Number 2 Question.")
  fill_in("archive_faq_questions_attributes_1_content", with: "This is an answer to the second question")
  fill_in("archive_faq_questions_attributes_1_anchor", with: "whatisao32")
  fill_in("archive_faq_questions_attributes_2_question", with: "Number 3 Question.")
  fill_in("archive_faq_questions_attributes_2_content", with: "This is an answer to the third question")
  fill_in("archive_faq_questions_attributes_2_anchor", with: "whatisao33")
  click_button("Post")
end

When /^there are (\d+) Archive FAQs$/ do |n|
  (1..n.to_i).each do |i|
    step %{I make a #{i} FAQ post}
  end
end

When /^(\d+) Archive FAQs? exists?$/ do |n|
  (1..n.to_i).each do |i|
    FactoryBot.create(:archive_faq, id: i)
  end
end

When /^the invite_from_queue_at is yesterday$/ do
  AdminSetting.first.update_attribute(:invite_from_queue_at, Time.now - 1.day)
end

When /^the check_queue rake task is run$/ do
  step %{I run the rake task "invitations:check_queue"}
end

When /^I edit known issues$/ do
  step %{I am logged in as an admin}
  step %{I follow "Admin Posts"}
  step %{I follow "Known Issues" within "#header"}
  step %{I follow "Edit"}
  step %{I fill in "known_issue_title" with "More known problems"}
  step %{I fill in "content" with "This is a bit of a problem, and this is too"}
  step %{I press "Post"}
end

When /^I delete known issues$/ do
  step %{I am logged in as an admin}
  step %{I follow "Admin Posts"}
  step %{I follow "Known Issues" within "#header"}
  step %{I follow "Delete"}
end

When /^I uncheck the "([^\"]*)" role checkbox$/ do |role|
  role_name = role.parameterize.underscore
  role_id = Role.find_by(name: role_name).id
  uncheck("user_roles_#{role_id}")
end

When (/^I make a translation of an admin post( with tags)?$/) do |with_tags|
  admin_post = AdminPost.find_by(title: "Default Admin Post")
  # If post doesn't exist, assume we want to reference a non-existent post
  admin_post_id = !admin_post.nil? ? admin_post.id : 0
  visit new_admin_post_path
  fill_in("admin_post_title", with: "Deutsch Ankuendigung")
  fill_in("content", with: "Deutsch Woerter")
  step %{I select "Deutsch" from "Choose a language"}
  fill_in("admin_post_translated_post_id", with: admin_post_id)
  fill_in("admin_post_tag_list", with: "quotes, futurama") if with_tags
  click_button("Post")
end

When /^I hide the work "(.*?)"$/ do |title|
  work = Work.find_by(title: title)
  visit work_path(work)
  step %{I follow "Hide Work"}
end

### THEN

Then (/^the translation information should still be filled in$/) do
  step %{the "admin_post_title" field should contain "Deutsch Ankuendigung"}
  step %{the "content" field should contain "Deutsch Woerter"}
  step %{"Deutsch" should be selected within "Choose a language"}
end

Then (/^I should see a translated admin post$/) do
  step %{I go to the admin-posts page}
  step %{I should see "Default Admin Post"}
  step %{I should see "Translations: Deutsch"}
  step %{I follow "Default Admin Post"}
  step %{I should see "Deutsch" within "dd.translations"}
  step %{I follow "Deutsch"}
  step %{I should see "Deutsch Woerter"}
end

Then (/^I should see a translated admin post with tags$/) do
  step %{I go to the admin-posts page}
  step %{I should see "Default Admin Post"}
  step %{I should see "Tags: quotes futurama"}
  step %{I should see "Translations: Deutsch"}
  step %{I follow "Default Admin Post"}
  step %{I should see "Deutsch" within "dd.translations"}
  step %{I should see "futurama" within "dd.tags"}
end

Then (/^I should not see a translated admin post$/) do
  step %{I go to the admin-posts page}
  step %{I should see "Default Admin Post"}
  step %{I should see "Deutsch Ankuendigung"}
  step %{I follow "Default Admin Post"}
  step %{I should not see "Translations: Deutsch"}
end

Then /^the work "([^\"]*)" should be hidden$/ do |work|
  w = Work.find_by_title(work)
  user = w.pseuds.first.user.login
  step %{logged out users should not see the hidden work "#{work}" by "#{user}"}
  step %{logged in users should not see the hidden work "#{work}" by "#{user}"}
end

Then /^the work "([^\"]*)" should not be hidden$/ do |work|
  w = Work.find_by_title(work)
  user = w.pseuds.first.user.login
  step %{logged out users should see the unhidden work "#{work}" by "#{user}"}
  step %{logged in users should see the unhidden work "#{work}" by "#{user}"}
end

Then /^logged out users should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am logged out}
  step %{I should not see the hidden work "#{work}" by "#{user}"}
end

Then /^logged in users should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am logged in as a random user}
  step %{I should not see the hidden work "#{work}" by "#{user}"}
end

Then /^I should not see the hidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am on #{user}'s works page}
  step %{I should not see "#{work}"}
  step %{I view the work "#{work}"}
  step %{I should see "Sorry, you don't have permission to access the page you were trying to reach."}
end

Then /^"([^\"]*)" should see their work "([^\"]*)" is hidden?/ do |user, work|
  step %{I am logged in as "#{user}"}
  step %{I am on my works page}
  step %{I should not see "#{work}"}
  step %{I view the work "#{work}"}
  step %{I should see the image "title" text "Hidden by Administrator"}
end

Then /^logged out users should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am logged out}
  step %{I should see the unhidden work "#{work}" by "#{user}"}
end

Then /^logged in users should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am logged in as a random user}
  step %{I should see the unhidden work "#{work}" by "#{user}"}
end

Then /^I should see the unhidden work "([^\"]*)" by "([^\"]*)"?/ do |work, user|
  step %{I am on #{user}'s works page}
  step %{I should see "#{work}"}
  step %{I view the work "#{work}"}
  step %{I should see "#{work}"}
end

Then(/^the work "(.*?)" should not be deleted$/) do |work|
  w = Work.find_by(title: work)
  assert w && w.posted?
end

Then(/^there should be no bookmarks on the work "(.*?)"$/) do |work|
  w = Work.find_by(title: work)
  assert w.bookmarks.count == 0
end

Then(/^there should be no comments on the work "(.*?)"$/) do |work|
  w = Work.find_by(title: work)
  assert w.comments.count == 0
end

When(/^the user "(.*?)" is unbanned in the background/) do |user|
  u = User.find_by(login: user)
  u.update_attribute(:banned, false)
end

Given(/^I have blacklisted the address "([^"]*)"$/) do |email|
  visit admin_blacklisted_emails_url
  fill_in("Email", with: email)
  click_button("Add To Blacklist")
end

Given(/^I have blacklisted the address for user "([^"]*)"$/) do |user|
  visit admin_blacklisted_emails_url
  u = User.find_by(login: user)
  fill_in("admin_blacklisted_email_email", with: u.email)
  click_button("Add To Blacklist")
end

Then(/^the address "([^"]*)" should be in the blacklist$/) do |email|
  visit admin_blacklisted_emails_url
  fill_in("Email to find", with: email)
  click_button("Search Blacklist")
  assert page.should have_content(email)
end

Then(/^the address "([^"]*)" should not be in the blacklist$/) do |email|
  visit admin_blacklisted_emails_url
  fill_in("Email to find", with: email)
  click_button("Search Blacklist")
  step %{I should see "0 emails found"}
end

Then(/^I should not be able to comment with the address "([^"]*)"$/) do |email|
  step %{the work "New Work"}
  step %{I post the comment "I loved this" on the work "New Work" as a guest with email "#{email}"}
  step %{I should see "has been blocked at the owner's request"}
  step %{I should not see "Comment created!"}
end

Then(/^I should be able to comment with the address "([^"]*)"$/) do |email|
  step %{the work "New Work"}
  step %{I post the comment "I loved this" on the work "New Work" as a guest with email "#{email}"}
  step %{I should not see "has been blocked at the owner's request"}
  step %{I should see "Comment created!"}
end

Then /^the work "([^\"]*)" should be marked as spam/ do |work|
  w = Work.find_by_title(work)
  assert w.spam?
end

Then /^the work "([^\"]*)" should not be marked as spam/ do |work|
  w = Work.find_by_title(work)
  assert !w.spam?
end
