### GIVEN

Given /^I have no collections$/ do
  Collection.delete_all
end

Given /^the collection "([^\"]*)" is deleted$/ do |collection_title|
  step %{I am logged in as the owner of "#{collection_title}"}
  visit edit_collection_path(Collection.find_by(title: collection_title))
  click_link "Delete Collection"
  click_button "Yes, Delete Collection"
  page.should have_content("Collection was successfully deleted.")
end

When /^I am logged in as the owner of "([^\"]*)"$/ do |collection|
  c = Collection.find_by(title: collection)
  step %{I am logged in as "#{c.owners.first.user.login}"}
end

When /^I view the collection "([^\"]*)"$/ do |collection|
  visit collection_path(Collection.find_by(title: collection))
end

When /^I add my work to the collection$/ do
  step %{I follow "Add To Collection"}
  fill_in("collection_names", with: "Various_Penguins")
  click_button("Add")
end

When "I invite the work {string} to the collection {string}" do |work_title, collection_title|
  work = Work.find_by(title: work_title)
  collection = Collection.find_by(title: collection_title)
  visit work_path(work)
  click_link("Invite To Collections")
  fill_in("collection_names", with: collection.name)
  click_button("Invite")
end

When "I edit the work {string} to be in the collection(s) {string}" do |work, collection|
  step %{I edit the work "#{work}"}
  fill_in("Post to Collections / Challenges", with: collection)
  step %{I update the work}
end

When /^I view the ([^"]*) collection items page for "(.*?)"$/ do |item_status, collection|
  c = Collection.find_by(title: collection)
  if item_status == "approved"
    visit collection_items_path(c, status: "approved")
  elsif item_status == "rejected by user"
    visit collection_items_path(c, status: "rejected_by_user")
  elsif item_status == "rejected by collection"
    visit collection_items_path(c, status: "rejected_by_collection")
  elsif item_status == "awaiting user approval"
    visit collection_items_path(c, status: "unreviewed_by_user")
  elsif item_status == "awaiting collection approval"
    visit collection_items_path(c)
  end
end

When "the collection counts have expired" do
  step "all indexing jobs have been run"
  step "it is currently #{ArchiveConfig.SECONDS_UNTIL_COLLECTION_COUNTS_EXPIRE} seconds from now"
end

When "the collection blurb cache has expired" do
  step "it is currently #{ArchiveConfig.MINUTES_UNTIL_COLLECTION_BLURBS_EXPIRE} minutes from now"
end

Given /^mod1 lives in Alaska$/ do
  step %{I am logged in as "mod1"}
  step %{I go to mod1 preferences page}
  step %{I select "(GMT-09:00) Alaska" from "preference_time_zone"}
  step %{I press "Update"}
end

Given /^(?:I have )?(?:a|an|the) (hidden)?(?: )?(anonymous)?(?: )?(moderated)?(?: )?(closed)?(?: )?collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |hidden, anon, moderated, closed, title, name|
  mod = ensure_user("moderator")
  collection = FactoryBot.create(:collection, title: title, name: (name.presence || title.gsub(/[^\w]/, "_")), owner: mod.default_pseud)
  collection.collection_preference.update_attribute(:anonymous, true) if anon.present?
  collection.collection_preference.update_attribute(:unrevealed, true) if hidden.present?
  collection.collection_preference.update_attribute(:moderated, true) if moderated.present?
  collection.collection_preference.update_attribute(:closed, true) if closed.present?
end

Given "{string} owns the collection {string} with name {string}" do |owner, title, name|
  user = ensure_user(owner)
  FactoryBot.create(:collection, title: title, name: (name.presence || title.gsub(/[^\w]/, "_")), owner: user.default_pseud)
end

Given /^I open the collection with the title "([^\"]*)"$/ do |title|
  step %{I am logged in as "moderator"}
  visit collection_path(Collection.find_by(title: title))
  step %{I follow "Collection Settings"}
  step %{I uncheck "This collection is closed"}
  step %{I submit}
  step %{I am logged out}
end

Given /^I close the collection with the title "([^\"]*)"$/ do |title|
  step %{I am logged in as "moderator"}
  visit collection_path(Collection.find_by(title: title))
  step %{I follow "Collection Settings"}
  step %{I check "This collection is closed"}
  step %{I submit}
  step %{I am logged out}
end

Given "I have added a/the co-moderator {string} to collection {string}" do |name, title|
  # create the user
  step %{I am logged in as "#{name}"}
  step %{I am logged in as the owner of "#{title}"}
  visit collection_path(Collection.find_by(title: title))
  click_link("Membership")
  step %{I fill in "participants_to_invite" with "#{name}"}
  step %{I press "Submit"}

  step %{I select "Moderator" from "#{name}_role"}
  # TODO: fix the form, it is malformed right now
  click_button("#{name}_submit")
  step %{I should see "Updated #{name}"}
end

Given "I have added a/the co-owner {string} to collection {string}" do |name, title|
  # create the user
  step %{I am logged in as "#{name}"}
  step %{I am logged in as the owner of "#{title}"}
  visit collection_path(Collection.find_by(title: title))
  click_link("Membership")
  step %{I fill in "participants_to_invite" with "#{name}"}
  step %{I press "Submit"}

  step %{I select "Owner" from "#{name}_role"}
  # TODO: fix the form, it is malformed right now
  click_button("#{name}_submit")
  step %{I should see "Updated #{name}"}
end

Given "I have joined the collection {string} as {string}" do |title, login|
  collection = Collection.find_by(title: title)
  user = User.find_by(login: login)
  FactoryBot.create(:collection_participant, pseud: user.default_pseud, collection: collection, participant_role: "Member")
  visit collections_path
end

Given "a set of collections for searching" do
  profile = CollectionProfile.create!(faq: "<dl><dt>What is this test thing?</dt><dd>It's a test collection</dd></dl>",
                                      intro: "Welcome to the test collection",
                                      rules: "Be nice to testers")
  FactoryBot.create(:collection,
                    name: "sometest",
                    title: "Some Test Collection",
                    tag_string: "The Best Tag, The Better Tag",
                    collection_profile: profile)
  FactoryBot.create(:collection,
                    name: "othertest",
                    tag_string: "The Best Tag",
                    title: "Some Other Collection")
  FactoryBot.create(:collection,
                    :closed,
                    name: "anothertest",
                    tag_string: "The Better Tag",
                    title: "Another Plain Collection")
  FactoryBot.create(:collection,
                    :moderated,
                    name: "surprisetest",
                    title: "Surprise Presents",
                    challenge: FactoryBot.create(:gift_exchange))
  FactoryBot.create(:collection,
                    name: "swaptest",
                    title: "Another Gift Swap",
                    multifandom: true,
                    challenge: FactoryBot.create(:gift_exchange))
  FactoryBot.create(:collection,
                    :closed,
                    name: "demandtest",
                    title: "On Demand",
                    challenge: FactoryBot.create(:prompt_meme))

  step %{all indexing jobs have been run}
end

### WHEN

When /^I set up (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  visit new_collection_path
  fill_in("collection_name", with: (name.presence || title.gsub(/[^\w]/, "_")))
  fill_in("collection_title", with: title)
end

When /^I create (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  name = title.gsub(/[^\w]/, "_") if name.blank?
  step %{I set up the collection "#{title}" with name "#{name}"}
  step %{I submit}
end

When /^I add (?:a|the) subcollection "([^"]*)"(?: with name "([^"]*)")? to (?:a|the) parent collection named "([^"]*)"$/ do |title, name, parent_name|
  step %{I create the collection "#{parent_name}" with name "#{parent_name}"} if Collection.find_by_name(parent_name).nil?
  name = title.gsub(/[^\w]/, "_") if name.blank?
  step %{I set up the collection "#{title}" with name "#{name}"}
  fill_in("collection_parent_name", with: parent_name)
  step %{I submit}
end

When /^I sort by fandom$/ do
  within(:xpath, "//li[a[contains(@title,'Sort')]]") do
    step %{I follow "Fandom 1"}
  end
end

When /^I reveal works for "([^\"]*)"$/ do |title|
  step %{I am logged in as the owner of "#{title}"}
  visit collection_path(Collection.find_by(title: title))
  step %{I follow "Collection Settings"}
  uncheck "This collection is unrevealed"
  click_button "Update"
  page.should have_content("Collection was successfully updated")
end

When /^I reveal authors for "([^\"]*)"$/ do |title|
  step %{I am logged in as the owner of "#{title}"}
  visit collection_path(Collection.find_by(title: title))
  step %{I follow "Collection Settings"}
  uncheck "This collection is anonymous"
  click_button "Update"
  page.should have_content("Collection was successfully updated")
end

When /^I check all the collection settings checkboxes$/ do
  check("collection_collection_preference_attributes_moderated")
  check("collection_collection_preference_attributes_closed")
  check("collection_collection_preference_attributes_unrevealed")
  check("collection_collection_preference_attributes_anonymous")
  check("collection_collection_preference_attributes_show_random")
  check("collection_collection_preference_attributes_email_notify")
end

When "{string} accepts the invitation for their work in the collection {string}" do |username, collection|
  the_collection = Collection.find_by(title: collection)
  collection_item_id = the_collection.collection_items.first.id
  visit user_collection_items_path(User.find_by(login: username))
  step %{I select "Approved" from "collection_items_#{collection_item_id}_user_approval_status"}
end

When "I approve the work {string} in the collection {string}" do |work, collection|
  work = Work.find_by(title: work)
  collection = Collection.find_by(title: collection)
  item_id = CollectionItem.find_by(item: work, collection: collection).id
  visit collection_items_path(collection)
  step %{I select "Approved" from "collection_items_#{item_id}_collection_approval_status"}
end

When "I give {string} the {string} role in the collection {string}" do |byline, role, collection|
  pseud = Pseud.parse_byline(byline)
  collection = Collection.find_by(title: collection)
  participant_id = CollectionParticipant.find_by(pseud: pseud, collection: collection).id
  selector = "#participant_#{participant_id}"
  step %{I select "#{role}" from "#{pseud.user.login}_role" within "#{selector}"}
  step %{I press "Update" within "#{selector}"}
end

### THEN

Then /^"([^"]*)" collection exists$/ do |title|
  assert Collection.where(title: title).exists?
end

Then /^the name of the collection "([^"]*)" should be "([^"]*)"$/ do |title, name|
  assert Collection.find_by(title: title).name == name
end

Then /^I should see a collection not found message for "([^\"]+)"$/ do |collection_name|
  step %{I should see /We couldn't find the collection(?:.+and)? #{collection_name}/}
end

Then /^the collection "(.*)" should be deleted/ do |collection|
  assert Collection.where(title: collection).first.nil?
end

Then /^the work "([^\"]*)" should be hidden from me$/ do |title|
  work = Work.find_by(title: title)
  visit work_path(work)
  expect(page.title).to include("Mystery Work")
  expect(page.title).not_to include(title)
  expect(page).not_to have_content(title)
  expect(page).to have_content("This work is part of an ongoing challenge and will be revealed soon!")
  expect(page).not_to have_content(Sanitize.clean(work.chapters.first.content))
  if work.collections.first
    step "all indexing jobs have been run"
    visit collection_path(work.collections.first)
    expect(page).not_to have_content(title)
    expect(page).to have_content("Mystery Work")
  end
  visit user_path(work.users.first)
  expect(page).not_to have_content(title)
end

Then /^the work "([^\"]*)" should be visible to me$/ do |title|
  work = Work.find_by(title: title)
  visit work_path(work)
  page.should have_content(title)
  page.should have_content(Sanitize.clean(work.chapters.first.content))
end

Then /^the author of "([^\"]*)" should be visible to me on the work page$/ do |title|
  work = Work.find_by(title: title)
  visit work_path(work)
  authors = work.pseuds.uniq.sort.collect(&:byline).join(", ")
  page.should have_content("Anonymous [#{authors}]")
end

Then /^the author of "([^\"]*)" should be publicly visible$/ do |title|
  work = Work.find_by(title: title)
  byline = work.users.first.pseuds.first.byline
  visit work_path(work)
  expect(page.title).to include(byline)
  step %{I should see "#{byline}" within ".byline"}
  if work.collections.first
    step "all indexing jobs have been run"
    visit collection_path(work.collections.first)
    expect(page).to have_content("#{title} by #{byline}")
  end
end

Then /^the author of "([^\"]*)" should be hidden from me$/ do |title|
  step "all indexing jobs have been run"
  work = Work.find_by(title: title)
  byline = work.users.first.pseuds.first.byline
  visit work_path(work)
  expect(page).not_to have_content(byline)
  expect(page.title).to include("Anonymous")
  step %{I should see "Anonymous" within ".byline"}
  visit collection_path(work.collections.first)
  expect(page).not_to have_content("#{title} by #{byline}")
  expect(page).to have_content("#{title} by Anonymous")
  visit user_path(work.users.first)
  expect(page).not_to have_content(title)
end

Then "{string} should have the {string} role in the collection {string}" do |byline, role, collection|
  pseud = Pseud.parse_byline(byline)
  collection = Collection.find_by(title: collection)
  participant_id = CollectionParticipant.find_by(pseud: pseud, collection: collection).id
  selector = "#participant_#{participant_id}"
  within(selector) do
    expect(page).to have_select("#{pseud.user.login}_role", selected: role)
  end
end
