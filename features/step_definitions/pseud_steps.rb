Given /^"([^"]*)" has the pseud "([^"]*)"$/ do |username, pseud|
  u = ensure_user(username)
  u.pseuds.create!(name: pseud)
end

Given "there are {int} pseuds per page" do |amount|
  stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
  ArchiveConfig.ITEMS_PER_PAGE = amount.to_i
  allow(Pseud).to receive(:per_page).and_return(amount)
end

When "{string} changes the pseud {string} to {string}" do |username, old_pseud, new_pseud|
  step %{"#{username}" edits the pseud "#{old_pseud}"}
  fill_in("Name", with: new_pseud)
  click_button("Update")
end

When "{string} edits the pseud {string}" do |username, pseud|
  p = Pseud.where(name: pseud, user_id: User.find_by(login: username)).first
  visit edit_user_pseud_path(User.find_by(login: username), p)
end

When "{string} deletes the pseud {string}" do |username, pseud|
  visit user_pseuds_path(User.find_by(login: username))
  click_link("delete_#{pseud}")
end

When /^"([^\"]*)" creates the default pseud "([^"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", with: newpseud
  check("pseud_is_default")
  click_button "Create"
end

When /^"([^"]*)" creates the pseud "([^"]*)"$/ do |username, newpseud|
  visit new_user_pseud_path(username)
  fill_in "Name", with: newpseud
  click_button "Create"
end

When "I fill in details of my default pseud" do
  step("I want to edit my profile")
  click_link("Edit Default Pseud and Icon")
  fill_in("Description", with: "Description thingy")
  fill_in("Icon alt text", with: "Icon alt text thingy")
  fill_in("Icon comment text", with: "Icon comment text thingy")
  step("I attach an icon with the extension 'png'")
  click_button("Update")
end

Then "the pseud {string} should not have an icon, alt text and comment text" do |pseud_name|
  pseud = Pseud.find_by(name: pseud_name)

  expect !pseud.icon.attached?
  expect pseud.icon_alt_text.blank?
  expect pseud.icon_comment_text.blank?
end
