### GIVEN

Given /^I have no tags$/ do
  # Tag.delete_all if Tag.count > 1
  # silence_warnings {load "#{Rails.root}/app/models/fandom.rb"}
end

Given /^basic tags$/ do
  step %{the default ratings exist}
  step %{the basic warnings exist}
  Fandom.find_or_create_by_name_and_canonical("No Fandom", true)
  step %{the basic categories exist}
end

Given /^the default ratings exist$/ do
  ratings = [ArchiveConfig.RATING_DEFAULT_TAG_NAME,
             ArchiveConfig.RATING_GENERAL_TAG_NAME,
             ArchiveConfig.RATING_TEEN_TAG_NAME,
             ArchiveConfig.RATING_MATURE_TAG_NAME,
             ArchiveConfig.RATING_EXPLICIT_TAG_NAME]
  ratings.each do |rating|
    Rating.find_or_create_by_name_and_canonical(rating, true)
  end
end

Given /^the basic warnings exist$/ do
  Warning.find_or_create_by_name_and_canonical("No Archive Warnings Apply", true)
  Warning.find_or_create_by_name_and_canonical("Choose Not To Use Archive Warnings", true)
end

Given /^the basic categories exist$/ do
  %w(Gen Other F/F Multi F/M M/M).each do |category|
    Category.find_or_create_by_name_and_canonical(category, true)
  end
end

Given /^I have a canonical "([^\"]*)" fandom tag named "([^\"]*)"$/ do |media, fandom|
  fandom = Fandom.find_or_create_by_name_and_canonical(fandom, true)
  media = Media.find_or_create_by_name_and_canonical(media, true)
  fandom.add_association media
end

Given /^I add the fandom "([^\"]*)" to the character "([^\"]*)"$/ do |fandom, character|
  char = Character.find_or_create_by_name(character)
  fand = Fandom.find_or_create_by_name(fandom)
  char.add_association(fand)
end

Given /^a canonical character "([^\"]*)" in fandom "([^\"]*)"$/ do |character, fandom|
  char = Character.find_or_create_by_name_and_canonical(character, true)
  fand = Fandom.find_or_create_by_name_and_canonical(fandom, true)
  char.add_association(fand)
end

Given /^a canonical relationship "([^\"]*)" in fandom "([^\"]*)"$/ do |relationship, fandom|
  rel = Relationship.find_or_create_by_name_and_canonical(relationship, true)
  fand = Fandom.find_or_create_by_name_and_canonical(fandom, true)
  rel.add_association(fand)
end

Given /^a canonical (\w+) "([^\"]*)"$/ do |tag_type, tagname|
  t = tag_type.classify.constantize.find_or_create_by_name(tagname)
  t.canonical = true
  t.save
end

Given /^a noncanonical (\w+) "([^\"]*)"$/ do |tag_type, tagname|
  t = tag_type.classify.constantize.find_or_create_by_name(tagname)
  t.canonical = false
  t.save
end

Given /^a synonym "([^\"]*)" of the tag "([^\"]*)"$/ do |synonym, merger|
  merger = Tag.find_by_name(merger)
  merger_type = merger.type

  synonym = merger_type.classify.constantize.find_or_create_by_name(synonym)
  synonym.merger = merger
  synonym.save
end

Given /^"([^\"]*)" is a metatag of the fandom "([^\"]*)"$/ do |metatag, fandom|
  fandom = Fandom.find_or_create_by_name(fandom)
  metatag = Fandom.find_or_create_by_name(metatag)
  fandom.meta_tags << metatag
  fandom.save
end

Given /^I am logged in as a tag wrangler$/ do
  step "I am logged out"
  username = "wrangler"
  step %{I am logged in as "#{username}"}
  user = User.find_by_login(username)
  user.tag_wrangler = '1'
end

Given /^the tag wrangler "([^\"]*)" with password "([^\"]*)" is wrangler of "([^\"]*)"$/ do |user, password, fandomname|
  tw = User.find_by_login(user)
  if tw.blank?
    tw = FactoryGirl.create(:user, {:login => user, :password => password})
    tw.activate
  else
    tw.password = password
    tw.password_confirmation = password
    tw.save
  end
  tw.tag_wrangler = '1'
  visit logout_path
  assert !UserSession.find
  visit login_path
  fill_in "User name", :with => user
  fill_in "Password", :with => password
  check "Remember Me"
  click_button "Log In"
  assert UserSession.find
  fandom = Fandom.find_or_create_by_name_and_canonical(fandomname, true)
  visit tag_wranglers_url
  fill_in "tag_fandom_string", :with => fandomname
  click_button "Assign"
end

Given /^a tag "([^\"]*)" with(?: (\d+))? comments$/ do |tagname, n_comments|
  tag = Fandom.find_or_create_by_name(tagname)
  step %{I am logged out}
  n_comments ||= 3
  n_comments.to_i.times do |i|
    step %{I am logged in as a tag wrangler}
    step %{I post the comment "Comment number #{i}" on the tag "#{tagname}"}
    step %{I am logged out}
  end
end

Given /^the canonical fandom "([^"]*)" with (\d+) works$/ do |tag_name, number_of_works|
  FactoryGirl.create(:fandom, name: tag_name, canonical: true)
  number_of_works.to_i.times do
    FactoryGirl.create(:work, posted: true, fandom_string: tag_name)
  end
end

Given /^a period-containing tag "([^\"]*)" with(?: (\d+))? comments$/ do |tagname, n_comments|
  tag = Fandom.find_or_create_by_name(tagname)
  step %{I am logged out}
  n_comments ||= 3
  n_comments.to_i.times do |i|
    step %{I am logged in as a tag wrangler}
    step %{I post the comment "Comment number #{i}" on the period-containing tag "#{tagname}"}
    step %{I am logged out}
  end
end

Given /^the unsorted tags setup$/ do
  30.times do |i|
    UnsortedTag.find_or_create_by_name("unsorted tag #{i}")
  end
end

Given /^I have posted a Wrangling Guideline?(?: titled "([^\"]*)")?$/ do |title|
  step %{I am logged in as an admin}
  visit new_wrangling_guideline_path
  if title
    fill_in("Guideline text", with: "This is a page about how we wrangle things.")
    fill_in("Title", with: title)
    click_button("Post")
  else
    step %{I make a 1st Wrangling Guideline}
  end
end

Given(/^the following typed tags exists$/) do |table|
  table.hashes.each do |hash|
    type = hash["type"].classify.constantize
    hash.delete("type")
    FactoryGirl.create(type, hash)
  end
end

### WHEN

When /^the periodic tag count task is run$/i do
  Tag.write_redis_to_database
end

When /^I check the canonical option for the tag "([^"]*)"$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  check("canonicals_#{tag.id}")
end

When /^I select "([^"]*)" for the unsorted tag "([^"]*)"$/ do |type, tagname|
  tag = Tag.find_by_name(tagname)
  select(type, :from => "tags[#{tag.id}]")
end

When /^I check the (?:mass )?wrangling option for "([^"]*)"$/ do |tagname|
  tag = Tag.find_by_name(tagname)
  check("selected_tags_#{tag.id}")
end

When /^I edit the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  within(".header") do
    click_link("Edit")
  end
end

When /^I view the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
end

When /^I create the fandom "([^\"]*)" with id (\d+)$/ do |name, id|
 tag = Fandom.new(:name => name)
 tag.id = id.to_i
 tag.canonical = true
 tag.save
end

When /^I set up the comment "([^"]*)" on the tag "([^"]*)"$/ do |comment_text, tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  click_link(" comment")
  fill_in("Comment", :with => comment_text)
end

When /^I post the comment "([^"]*)" on the tag "([^"]*)"$/ do |comment_text, tag|
  step "I set up the comment \"#{comment_text}\" on the tag \"#{tag}\""
  click_button("Comment")
end

When /^I post the comment "([^"]*)" on the period-containing tag "([^"]*)"$/ do |comment_text, tag|
  step "I am on the search tags page"
  fill_in("tag_search", with: tag)
  click_button "Search tags"
  click_link(tag)
  click_link(" comment")
  fill_in("Comment", with: comment_text)
  click_button("Comment")
end

When /^I post the comment "([^"]*)" on the tag "([^"]*)" via web$/ do |comment_text, tag|
  step %{I view the tag "#{tag}"}
  step %{I follow " comments"}
    step %{I fill in "Comment" with "#{comment_text}"}
    step %{I press "Comment"}
  step %{I should see "Comment created!"}
end

When /^I view tag wrangling discussions$/ do
  step %{I follow "Tag Wrangling"}
  step %{I follow "Discussion"}
end

When /^I add "([^\"]*)" to my favorite tags$/ do |tag|
  step %{I view the "#{tag}" works index}
  step %{I press "Favorite Tag"}
end

When /^I remove "([^\"]*)" from my favorite tags$/ do |tag|
  step %{I view the "#{tag}" works index}
  step %{I press "Unfavorite Tag"}
end

When /^the tag "([^\"]*)" is decanonized$/ do |tag|
  tag = Tag.find_by_name!(tag)
  tag.canonical = false
  tag.save
end

When /^I make a(?: (\d+)(?:st|nd|rd|th)?)? Wrangling Guideline$/ do |n|
  n ||= 1
  visit new_wrangling_guideline_path
  fill_in("Guideline text", :with => "Number #{n} posted Wrangling Guideline, this is.")
  fill_in("Title", :with => "Number #{n} Wrangling Guideline")
  click_button("Post")
end

When /^(\d+) Wrangling Guidelines? exists?$/ do |n|
  (1..n.to_i).each do |i|
    FactoryGirl.create(:wrangling_guideline, id: i)
  end
end

When /^I flush the wrangling sidebar caches$/ do
  [Fandom, Character, Relationship, Freeform].each do |klass|
    Rails.cache.delete("/wrangler/counts/sidebar/#{klass}")
  end
end

### THEN

Then /^I should see the tag wrangler listed as an editor of the tag$/ do
  step %{I should see "wrangler" within "fieldset dl"}
end

Then /^I should see the tag search result "([^\"]*)"(?: within "([^"]*)")?$/ do |result, selector|
    with_scope(selector) do
      page.has_text?(result)
    end
end

Then /^I should not see the tag search result "([^\"]*)"(?: within "([^"]*)")?$/ do |result, selector|
    with_scope(selector) do
      page.has_no_text?(result)
    end
end

Then /^"([^\"]*)" should not be a tag wrangler$/ do |username|
  user = User.find_by_login(username)
  user.tag_wrangler.should be_falsey
end

Then /^"([^\"]*)" should be assigned to the wrangler "([^\"]*)"$/ do |fandom, username|
  user = User.find_by_login(username)
  fandom = Fandom.find_by_name(fandom)
  assignment = WranglingAssignment.find(:first, conditions: { user_id: user.id, fandom_id: fandom.id })
  assignment.should_not be_nil
end

Then /^"([^\"]*)" should not be assigned to the wrangler "([^\"]*)"$/ do |fandom, username|
  user = User.find_by_login(username)
  fandom = Fandom.find_by_name(fandom)
  assignment = WranglingAssignment.find(:first, conditions: { user_id: user.id, fandom_id: fandom.id })
  assignment.should be_nil
end

Then(/^the "([^"]*)" tag should be a "([^"]*)" tag$/) do |tagname , tag_type|
  tag = Tag.find_by_name(tagname)
  assert tag.type == tag_type
end

Then(/^the "([^"]*)" tag should be canonical$/) do |tagname|
  tag = Tag.find_by_name(tagname)
  assert tag.canonical?
end

Then(/^show me what the tag "([^"]*)" is like$/) do |tagname|
  tag = Tag.find_by_name(tagname)
  puts tag.inspect
end
