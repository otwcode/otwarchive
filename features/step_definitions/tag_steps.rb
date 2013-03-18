### GIVEN

Given /^I have no tags$/ do
  # Tag.delete_all if Tag.count > 1
  # silence_warnings {load "#{Rails.root}/app/models/fandom.rb"}
end

Given /^basic tags$/ do
  Warning.find_or_create_by_name_and_canonical("No Archive Warnings Apply", true)
  Warning.find_or_create_by_name_and_canonical("Choose Not To Use Archive Warnings", true)
  Rating.find_or_create_by_name_and_canonical("Not Rated", true)
  Rating.find_or_create_by_name_and_canonical("Explicit", true)
  Fandom.find_or_create_by_name_and_canonical("No Fandom", true)
  Category.find_or_create_by_name_and_canonical("Other", true)
  Category.find_or_create_by_name_and_canonical("F/F", true)
  Category.find_or_create_by_name_and_canonical("Multi", true)
  Category.find_or_create_by_name_and_canonical("M/F", true)
  Category.find_or_create_by_name_and_canonical("M/M", true)
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
  char = Character.find_or_create_by_name_and_canonical(character)
  fand = Fandom.find_or_create_by_name_and_canonical(fandom)
  char.add_association(fand)
end

Given /^a canonical relationship "([^\"]*)" in fandom "([^\"]*)"$/ do |relationship, fandom|
  rel = Relationship.find_or_create_by_name_and_canonical(relationship)
  fand = Fandom.find_or_create_by_name_and_canonical(fandom)
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

Given /^I am logged in as a tag wrangler$/ do
  Given "I am logged out"
  username = "wrangler"
  Given %{I am logged in as "#{username}"}
  user = User.find_by_login(username)
  user.tag_wrangler = '1'
end

Given /^the tag wrangler "([^\"]*)" with password "([^\"]*)" is wrangler of "([^\"]*)"$/ do |user, password, fandomname|
  tw = User.find_by_login(user)
  if tw.blank?
    tw = Factory.create(:user, {:login => user, :password => password})
    tw.activate
  else
    tw.password = password
    tw.password_confirmation = password
    tw.save
  end
  tw.tag_wrangler = '1'
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

### WHEN

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
  Given "I set up the comment \"#{comment_text}\" on the tag \"#{tag}\""
  click_button("Comment")
end

When /^I post the comment "([^"]*)" on the tag "([^"]*)" via web$/ do |comment_text, tag|
  When %{I view the tag "#{tag}"}
  When %{I follow " comments"}
    And %{I fill in "Comment" with "#{comment_text}"}
    And %{I press "Comment"}
  Then %{I should see "Comment created!"}
end

When /^I view tag wrangling discussions$/ do
  When %{I follow "Tag Wrangling"}
  When %{I follow "Discussion"}
end

### THEN

Then /^I should see the tag wrangler listed as an editor of the tag$/ do
  Then %{I should see "wrangler" within ".tag_edit"}
end
