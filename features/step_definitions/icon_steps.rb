### GIVEN

Given /^I am editing a pseud$/ do
  step %{I am logged in as "myname"}
  visit edit_user_pseud_path(User.current_user, User.current_user.default_pseud)
end

#' cancelling highlighting

Given /^I have an icon uploaded$/ do
  step "I am editing a pseud"
  step %{I attach the file "test/fixtures/icon.gif" to "icon"}
    step %{I press "Update"}
end

### WHEN

When /^I add an icon to the collection$/ do
  step %{I am logged in as "moderator"}
    step %{I am on "Pretty" collection's page}
    step %{I follow "Settings"}
    step %{I attach the file "test/fixtures/icon.gif" to "collection_icon"}
    step %{I press "Update"}
end

### THEN
