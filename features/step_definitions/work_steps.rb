DEFAULT_TITLE = "My Work Title"
DEFAULT_FANDOM = "Stargate SG-1"
DEFAULT_RATING = "Not Rated"
DEFAULT_WARNING = "No Archive Warnings Apply"
DEFAULT_FREEFORM = "Scary tag"
DEFAULT_CONTENT = "That could be an amusing crossover."

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

When /^I post the chaptered work "([^\"]*)"$/ do |title|
  When %{I post the work "#{title}"}
  When %{I follow "Add Chapter"}
  fill_in("content", :with => "Another Chapter.")
  click_button("Preview")
  When %{I press "Post Chapter"}
end

When /^I post the work "([^\"]*)" in the collection "([^\"]*)"$/ do |title, collection|
  work = Work.find_by_title(title)
  if work.blank?
    Given "the draft \"#{title}\" in collection \"#{collection}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^I post the work "([^\"]*)" without preview$/ do |title|
  work = Work.find_by_title(title)
  if work.blank?
    Given %{I set up the draft "#{title}"}
    click_button("Post without preview")
    Then "I should see \"Work was successfully posted.\""
  end
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)" with freeform "([^\"]*)"$/ do |title, fandom, freeform|
  work = Work.find_by_title(title)
  if work.blank?
    Given %{the draft "#{title}" with fandom "#{fandom}" with freeform "#{freeform}"}
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
end

When /^I post the work "([^\"]*)"$/ do |title|
  When %{I post the work "#{title}" with fandom "#{DEFAULT_FANDOM}" with freeform "#{DEFAULT_FREEFORM}"}
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)"$/ do |title, fandom|
  When %{I post the work "#{title}" with fandom "#{fandom}" with freeform "#{DEFAULT_FREEFORM}"}
end

When /^I fill in the basic work information for "([^\"]*)"$/ do |title|
  When %{I fill in basic work tags}
  check(DEFAULT_WARNING)
  fill_in("Work Title", :with => title)
  fill_in("content", :with => DEFAULT_CONTENT)
end  

When /^I fill in basic work tags$/ do
  select(DEFAULT_RATING, :from => "Rating")
  fill_in("Fandoms", :with => DEFAULT_FANDOM)
  fill_in("Additional Tags", :with => DEFAULT_FREEFORM)
end

# TODO: The optional extras (fandom and freeform) in the When line don't seem to be working here - can anyone fix them?
When /^the draft "([^\"]*)"(?: with fandom "([^\"]*)")(?: with freeform "([^\"]*)")$/ do |title, fandom, freeform|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  fill_in("Fandoms", :with => fandom.nil? ? DEFAULT_FANDOM : fandom)
  fill_in("Additional Tags", :with => freeform.nil? ? DEFAULT_FREEFORM : freeform)
  click_button("Preview")
end

When /^the draft "([^\"]*)"(?: with fandom "([^\"]*)")$/ do |title, fandom|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  fill_in("Fandoms", :with => fandom.nil? ? DEFAULT_FANDOM : fandom)
  click_button("Preview")
end

When /^the draft "([^\"]*)" in collection "([^\"]*)"$/ do |title, collection|
  Given "basic tags"
  visit new_work_url
  Given "I fill in the basic work information for \"#{title}\""
  fill_in("Fandoms", :with => "Naruto")
  collection = Collection.find_by_title(collection)
  fill_in("Collections", :with => collection.name)
  click_button("Preview")
end

When /^I set up the draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
end

When /^the draft "([^\"]*)"$/ do |title|
  Given %{I set up the draft "#{title}"}
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
  Given %{I fill in the basic work information for "#{title}"}
  check("work_restricted")
  click_button("Preview")
  Then %{I should see "Draft was successfully created."}
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

When /^I browse the "([^"]+)" works$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  visit tag_works_path(tag)
end

When /^I browse the "([^"]+)" works with an empty page parameter$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  visit tag_works_path(tag, :page => "")
end
