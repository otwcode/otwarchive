DEFAULT_TITLE = "My Work Title"
DEFAULT_FANDOM = "Stargate SG-1"
DEFAULT_RATING = "Not Rated"
DEFAULT_WARNING = "No Archive Warnings Apply"
DEFAULT_FREEFORM = "Scary tag"
DEFAULT_CONTENT = "That could be an amusing crossover."
DEFAULT_CATEGORY = "Other"

### GIVEN

Given /^I have no works or comments$/ do
  Work.delete_all
  Comment.delete_all
end

Given /^the chaptered work(?: with ([\d]+) chapters)?(?: with ([\d]+) comments?)? "([^"]*)"$/ do |n_chapters, n_comments, title|
  Given %{I am logged in as a random user}
  And %{I post the work "#{title}"}
  work = Work.find_by_title!(title)
  visit work_url(work)
  n_chapters ||= 2
  (n_chapters.to_i - 1).times do |i|
    When %{I follow "Add Chapter"}
    fill_in("content", :with => "Yet another chapter.")
    click_button("Post without preview")
  end
  And %{I am logged out}
  n_comments ||= 0
  n_comments.to_i.times do |i|
    Given %{I am logged in as a random user}
    And %{I post the comment "Bla bla" on the work "#{title}"}
    And %{I am logged out}
  end
end

Given /^I have a work "([^\"]*)"$/ do |work|
  When "I am logged in as a random user"
    And %{I post the work "#{work}"}
end

Given /^I have a locked work "([^\"]*)"$/ do |work|
  When "I am logged in as a random user"
    And %{I post the locked work "#{work}"}
end

Given /^the work with(?: (\d+))? comments setup$/ do |n_comments|
  Given %{I have a work "Blabla"}
  And %{I am logged out}
  n_comments ||= 3
  n_comments.to_i.times do |i|
    Given %{I am logged in as a random user}
    And %{I post the comment "Keep up the good work" on the work "Blabla"}
    And %{I am logged out}
  end
end

Given /^the chaptered work setup$/ do
  Given %{the chaptered work with 3 chapters "BigBang"}
end

Given /^the chaptered work with comments setup$/ do
  Given %{the chaptered work with 3 chapters "BigBang"}
  When "I am logged in as a random user"
    And %{I view the work "BigBang"}
    And %{I post a comment "Woohoo"}
  (2..3).each do |i|
    And %{I view the work "BigBang"}
    And %{I view the #{i.to_s}th chapter}
    And %{I post a comment "Woohoo"}
  end
  And "I am logged out"
end

### WHEN

When /^I view the ([\d]+)(?:st|nd|rd|th) chapter$/ do |chapter_no|
  (chapter_no.to_i - 1).times do |i|
    When %{I follow "Next Chapter"}
  end
end

When /^I view the work "([^\"]*)"(?: in (full|chapter-by-chapter) mode)?$/ do |work, mode|
  work = Work.find_by_title!(work)
  visit work_url(work)
  When %{I follow "Entire Work"} if mode == "full"
  When %{I follow "View chapter by chapter"} if mode == "chapter-by-chapter"
end

When /^I view the work "([^\"]*)" with comments$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work, :anchor => "comments", :show_comments => true)
end

When /^I edit the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit edit_work_url(work)
end

When /^I post the chaptered work "([^\"]*)"$/ do |title|
  When %{I post the work "#{title}"}
  When %{I follow "Add Chapter"}
  fill_in("content", :with => "Another Chapter.")
  click_button("Preview")
  When %{I press "Post Chapter"}
  Work.tire.index.refresh
end

When /^I post the work "([^\"]*)" in the collection "([^\"]*)"$/ do |title, collection|
  work = Work.find_by_title(title)
  if work.blank?
    Given "the draft \"#{title}\" in collection \"#{collection}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Work.tire.index.refresh
  Then "I should see \"Work was successfully posted.\""
end

When /^I post the work "([^\"]*)" without preview$/ do |title|
  work = Work.find_by_title(title)
  if work.blank?
    Given %{I set up the draft "#{title}"}
    click_button("Post without preview")
    Work.tire.index.refresh
    Then "I should see \"Work was successfully posted.\""
  end
end

When /^a chapter is added to "([^\"]*)"$/ do |work_title|
  When %{a draft chapter is added to "#{work_title}"}
  click_button("Post Chapter")
  Work.tire.index.refresh
end

When /^a draft chapter is added to "([^\"]*)"$/ do |work_title|
  work = Work.find_by_title(work_title)
  user = work.users.first
  When %{I am logged in as "#{user.login}"}
  visit work_url(work)
  And %{I follow "Add Chapter"}
  And %{I fill in "content" with "la la la la la la la la la la la"}
  And %{I press "Preview"}  
  Work.tire.index.refresh
end

# meant to be used in conjunction with above step
When /^I post the draft chapter$/ do
  click_button("Post Chapter")
  Work.tire.index.refresh
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)" with freeform "([^\"]*)" with category "([^\"]*)"$/ do |title, fandom, freeform, category|
  work = Work.find_by_title(title)
  if work.blank?
    Given %{the draft "#{title}" with fandom "#{fandom}" with freeform "#{freeform}" with category "#{category}"}
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
  Work.tire.index.refresh
end

When /^I post the work "([^\"]*)"$/ do |title|
  When %{I post the work "#{title}" with fandom "#{DEFAULT_FANDOM}" with freeform "#{DEFAULT_FREEFORM}" with category "#{DEFAULT_CATEGORY}"}
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)"$/ do |title, fandom|
  When %{I post the work "#{title}" with fandom "#{fandom}" with freeform "#{DEFAULT_FREEFORM}" with category "#{DEFAULT_CATEGORY}"}
end

When /^I post the work "([^\"]*)" with category "([^\"]*)"$/ do |title, category|
  When %{I post the work "#{title}" with fandom "#{DEFAULT_FANDOM}" with freeform "#{DEFAULT_FREEFORM}" with category "#{category}"}
end

When /^I post a work with category "([^\"]*)"$/ do |category|
  When %{I post the work "#{DEFAULT_TITLE}" with fandom "#{DEFAULT_FANDOM}" with freeform "#{DEFAULT_FREEFORM}" with category "#{category}"}
end

When /^I post the work "([^\"]*)" with fandom "([^\"]*)" with freeform "([^\"]*)"$/ do |title, fandom, freeform|
  When %{I post the work "#{title}" with fandom "#{fandom}" with freeform "#{freeform}" with category "#{DEFAULT_CATEGORY}"}
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

# the (?: ) construct means: do not use the stuff in () as a capture/match
# the ()? construct means: the stuff in () is optional
# they must be combined so that the entire thing is optional, and only the relevant bits are captured
When /^the draft "([^\"]*)"(?: with fandom "([^\"]*)")?(?: with freeform "([^\"]*)")?(?: with category "([^\"]*)")?$/ do |title, fandom, freeform, category|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  check(category.nil? ? DEFAULT_CATEGORY : category)
  fill_in("Fandoms", :with => fandom.nil? ? DEFAULT_FANDOM : fandom)
  fill_in("Additional Tags", :with => freeform.nil? ? DEFAULT_FREEFORM : freeform)
  click_button("Preview")
end

When /^the draft "([^\"]*)" in collection "([^\"]*)"$/ do |title, collection|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  check(DEFAULT_CATEGORY)
  fill_in("Fandoms", :with => "Naruto")
  collection = Collection.find_by_title(collection)
  fill_in("Collections", :with => collection.name)
  click_button("Preview")
end

When /^I set up the draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  check(DEFAULT_CATEGORY)
end

When /^the purge_old_drafts rake task is run$/ do
  Work.purge_old_drafts
end

When /^the work "([^\"]*)" was created (\d+) days ago$/ do |title, number|
  Given "the draft \"#{title}\""
  work = Work.find_by_title(title)
  work.update_attribute(:created_at, number.to_i.days.ago)
  Work.tire.index.refresh
end

When /^I post the locked work "([^\"]*)"$/ do |title|
  work = Work.find_by_title(work)
  if work.blank?
    Given "the locked draft \"#{title}\""
    work = Work.find_by_title(title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Work.tire.index.refresh
end

When /^the locked draft "([^\"]*)"$/ do |title|
  Given "basic tags"
  visit new_work_url
  Given %{I fill in the basic work information for "#{title}"}
  check("work_restricted")
  click_button("Preview")
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

When /^I browse the "([^"]+)" works$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  visit tag_works_path(tag)
  Work.tire.index.refresh
end

When /^I browse the "([^"]+)" works with an empty page parameter$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  visit tag_works_path(tag, :page => "")
  Work.tire.index.refresh
end

When /^I delete the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  And %{I follow "Delete"}
  click_button("Yes, Delete Work")
  Work.tire.index.refresh
end

When /^I add my work to the collection$/ do
  When %{I follow "Add To Collection"}
  fill_in("collection_names", :with => "Various_Penguins")
  click_button("Add")
end

When /^I preview the work$/ do
  click_button("Preview")
  Work.tire.index.refresh
end

When /^I update the work$/ do
  click_button("Update")
  Work.tire.index.refresh
end

When /^I post the work without preview$/ do
  click_button "Post without preview"
  Work.tire.index.refresh
end

When /^I post the work$/ do
  click_button "Post"
  # Work.tire.index.refresh
end
### THEN

Then /^I should see Updated today$/ do
  today = Time.zone.today.to_s
  Given "I should see \"Updated:#{today}\""
end

Then /^I should not see Updated today$/ do
  today = Date.today.to_s
  Given "I should not see \"Updated:#{today}\""
end

