### GIVEN

Given /^I am editing a pseud$/ do
  Given %{I am logged in as "myname"}
  visit edit_user_pseud_path(User.current_user, User.current_user.default_pseud)
end

#' cancelling highlighting

Given /^I have an icon uploaded$/ do
  Given "I am editing a pseud"
  When %{I attach the file "test/fixtures/icon.gif" to "icon"}
    And %{I press "Update"}
end

### WHEN

When /^I add an icon to the collection$/ do
  When %{I am logged in as "moderator"}
    And %{I am on "Pretty" collection's page}
    #' cancelling highlighting
    And %{I follow "Settings"}
    And %{I attach the file "test/fixtures/icon.gif" to "collection_icon"}
    And %{I press "Update"}
end

### THEN
