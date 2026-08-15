Given /^I want to edit my profile$/ do
  step "I view my profile"
  click_link("Edit My Profile")
  step %{I should see "Edit My Profile"}
end

When /^I fill in the details of my profile$/ do
  fill_in("Title", with: "Test title thingy")
  fill_in("About Me", with: "This is some text about me.")
  click_button("Update")
end

When /^I change the details in my profile$/ do
  fill_in("Title", with: "Alternative title thingy")
  fill_in("About Me", with: "This is some different text about me.")
  click_button("Update")
end

When /^I remove details from my profile$/ do
  fill_in("Title", with: "")
  fill_in("About Me", with: "")
  click_button("Update")
end

When /^I view my profile$/ do
  step %{I follow "My Dashboard"}
  step %{I should see "Dashboard"}
  click_link("Profile")
end
