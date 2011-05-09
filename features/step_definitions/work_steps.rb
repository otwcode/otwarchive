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

When /^I post the chaptered work "([^\"]*)"$/ do |title|
  When "I post the work \"#{title}\""
  When "I follow \"Add Chapter\""
  fill_in("content", :with => "Another Chapter.")
  click_button("Preview")
  When "I press \"Post Chapter\""
end

When /^I post the work "([^\"]*)"$/ do |title|
  work = Work.find_by_title(title)
  if work.blank?
    Given "the draft \"#{title}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^I post the work "([^\"]*)" without preview$/ do |title|
  work = Work.find_by_title(title)
  if work.blank?
    Given "basic tags"
    visit new_work_url
    Given "I fill in the basic work information for \"#{title}\""
    click_button("Post without preview")
    Then "I should see \"Work was successfully posted.\""
  end
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)"$/ do |title, fandom|
  work = Work.find_by_title(title)
  if work.blank?
    Given "the draft \"#{title}\" with fandom \"#{fandom}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)" with freeform "([^\"]*)"$/ do |title, fandom, freeform|
  work = Work.find_by_title(title)
  if work.blank?
    Given "the draft \"#{title}\" with fandom \"#{fandom}\" with freeform \"#{freeform}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^I fill in the basic work information for "([^\"]*)"$/ do |title|
  select("Not Rated", :from => "Rating")
  check("No Archive Warnings Apply")
  fill_in("Fandoms", :with => "Stargate SG-1")
  fill_in("Work Title", :with => title)
  fill_in("Additional Tags", :with => "Scary tag")
  fill_in("content", :with => "That could be an amusing crossover.")
end  

# TODO: The optional extras (fandom and freeform) in the When line don't seem to be working here - can anyone fix them?
When /^the draft "([^\"]*)"(?: with fandom "([^\"]*)")(?: with freeform "([^\"]*)")$/ do |title, fandom, freeform|
  Given "basic tags"
  visit new_work_url
  Given "I fill in the basic work information for \"#{title}\""
  fill_in("Fandoms", :with => fandom.nil? ? "Stargate SG-1" : fandom)
  fill_in("Additional Tags", :with => freeform.nil? ? "Scary tag" : freeform)
  click_button("Preview")
end

When /^the draft "([^\"]*)"(?: with fandom "([^\"]*)")$/ do |title, fandom|
  Given "basic tags"
  visit new_work_url
  Given "I fill in the basic work information for \"#{title}\""
  fill_in("Fandoms", :with => fandom.nil? ? "Stargate SG-1" : fandom)
  click_button("Preview")
end

When /^I set up the draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  Given "I fill in the basic work information for \"#{title}\""
end

When /^the draft "([^\"]*)"$/ do |title|
  Given "I set up the draft \"#{title}\""
  click_button("Preview")
end

Then /^I should see Updated today$/ do
  today = Time.zone.today.to_s
  Given "I should see \"Updated:#{today}\""
end

Then /^I should not see Updated today$/ do
  today = Date.today.to_s
  Given "I should not see \"Updated:#{today}\""
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

When /^I set the publication date to today$/ do
  today = Time.new
  month = today.strftime("%B")
  
  check("backdate-options-show")
  select("#{today.day}", :from => "work[chapter_attributes][published_at(3i)]")
  select("#{month}", :from => "work[chapter_attributes][published_at(2i)]")
  select("#{today.year}", :from => "work[chapter_attributes][published_at(1i)]")
end

Given /^I view the chaptered work(?: with ([\d]+) comments?)? "([^"]*)"(?: in (full|chapter-by-chapter) mode)?$/ do |n_comments, title, mode|
  Given %{I am logged in as a random user}
  And %{I post the chaptered work "#{title}"}
  work = Work.find_by_title!(title)
  visit work_url(work)
  n_comments ||= 0
  n_comments.to_i.times do |i|
    Given %{I post the comment "Bla bla" on the work "#{title}"}
  end
  And %{I am logged out}
  visit work_url(work)
  And %{I follow "View Entire Work"} if mode == "full"
end
