When /^I view the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
end

When /^I edit the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  click_link("Edit")
end

Then /^(?:|I )should see work "([^\"]*)" with tags "([^\"]*)"$/ do |regexp, tags|
  regexp = Regexp.new(regexp)
  if defined?(Spec::Rails::Matchers)
    response.should contain(regexp)
  else
    assert_match(regexp, response_body)
  end
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
