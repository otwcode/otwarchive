Given /^"([^"]*)" has the pseud "([^"]*)"$/ do |username, pseud|
  step %{I am logged in as "#{username}"}
  step %{"#{username}" creates the pseud "#{pseud}"}
  step %{I start a new session}
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
