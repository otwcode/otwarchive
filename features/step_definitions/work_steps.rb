Given /^I have no works or comments$/ do
  Work.delete_all
  Comment.delete_all
end

When /^I view the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
end

When /^I edit the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  click_link("Edit")
end

When /^I edit the bookmark for "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  click_link("Edit/Add Bookmark")
end

When /^I post the work "([^\"]*)"$/ do |title|
  work = Work.find_by_title(work)
  if work.blank?
    Given "the draft \"#{title}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^the draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  select("Not Rated", :from => "Rating")
  check("No Archive Warnings Apply")
  fill_in("Fandoms", :with => "Stargate SG-1")
  fill_in("Work Title", :with => title)
  fill_in("Additional Tags", :with => "Scary tag")
  fill_in("content", :with => "That could be an amusing crossover.")
  click_button("Preview")
end

Then /^I should see Updated today$/ do
  today = Date.today.to_s
  Given "I should see \"Updated:#{today}\""
end

When /^the purge_old_drafts rake task is run$/ do
  Work.purge_old_drafts
end

When /^the work "([^\"]*)" was created (\d+) days ago$/ do |title, number|
  Given "the draft \"#{title}\""
  work = Work.find_by_title(title)
  work.update_attribute(:created_at, number.to_i.days.ago)
end

When /^I post the locked work "([^\"]*)"$/ do |title|
  work = Work.find_by_title(work)
  if work.blank?
    Given "the locked draft \"#{title}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^the locked draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  select("Not Rated", :from => "Rating")
  check("No Archive Warnings Apply")
  fill_in("Fandoms", :with => "Stargate SG-1")
  fill_in("Work Title", :with => title)
  fill_in("Additional Tags", :with => "Scary tag")
  check("work_restricted")
  fill_in("content", :with => "That could be an amusing crossover.")
  click_button("Preview")
  Then "I should see \"Draft was successfully created.\""
end

When /^I list the work "([^\"]*)" as inspiration$/ do |title|
  work = Work.find_by_title!(title)
  check("parent-options-show")
  url_of_work = work_url(work).sub("www.example.com", ArchiveConfig.APP_URL)
  fill_in("Url", :with => url_of_work)
end
