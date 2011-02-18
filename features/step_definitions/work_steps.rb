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
  When "I follow \"Post Chapter\""
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
###########################################################
DEFAULT_WORK =
  { :rating => "Not Rated",
    :warning => "No Archive Warnings Apply",
    :fandom => "Default Fandom",
    :title => "Default Title",
    :content => "Some content." }

def work(attributes = {})
  #This should be factoried at some point....
  attributes = DEFAULT_WORK.merge(attributes)
  visit new_work_url
  select(attributes[:rating], :from => "Rating")
  check(attributes[:warning])
  fill_in("Fandoms", :with => attributes[:fandom])
  fill_in("Work Title", :with => attributes[:title])
  fill_in("content", :with => attributes[:content])
  click_button("Preview")
  click_button("Post")
end
### Given
Given /^I have no works$/ do
  user.works.find_each { |w| w.delete }
end
Given /^I have (\d+) work(?:s)?$/ do |count|
  count.to_i.times do |i|
    work({:title => Faker::Lorem.words(3).join(" "), :content => Faker::Lorem.paragraphs(3).join})
  end
end
Given /^I have a work with the following chararistics$/ do |table|
  characteristics = table.rows_hash
  work(:title => characteristics['Title'], :fandom => characteristics['Fandom'])
end
Given /^I am previewing a work$/ do
  steps %Q{
  When I create a work with the following chararistics
    | Rating   | Not Rated                 |
    | Warnings | No Archive Warnings Apply |
    | Fandom   | Supernatural              |
    | Title    | All Hell Breaks Loose     |
    | Content  | Bad things happen, etc.   |
    }
  When %{preview my work}
end
### When
When /^I try to create a new work$/ do
  visit new_work_url
end
When /^I create a work with the following chararistics$/ do |table|
  characteristics = table.rows_hash
  visit new_work_url
  select(characteristics['Rating'], :from => "Rating")
  check(characteristics['Warnings'])
  fill_in("Fandoms", :with => characteristics['Fandom'])
  fill_in("Work Title", :with => characteristics['Title'])
  fill_in("content", :with => characteristics['Content'])
end
When /^(?:I )?post my work$/ do
  if page.has_content?("Post without preview")
    click_button("Post without preview")
  else
    click_button("Post")
  end
end
When /^preview my work$/ do
  click_button("Preview")
end
### Then
Then /^my work does not exist$/ do
  user.works.count.should == 0
end
Then /^my work is orphaned$/ do
  User.orphan_account.works.count.should == 1
end
Then /^I cannot create a work$/ do
  page.should have_content("Please log in")
end
Then /^my work should be posted$/ do
  page.should have_content("Work was successfully posted.")
end
Then /^I should see a preview$/ do
  page.should have_content("Preview Work")
end

