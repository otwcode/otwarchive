
When /^I follow the add new tagset link$/
  Given %{I follow "New Tag Set"}
end

When /^I fill in the tagset data$/ do 
  Given %{I fill in "Title" with "My Tagset"}
    And %{I fill in "Brief Description" with "Here's my tagset"}
    And %{I fill in "Fandoms to add:" with "Supernatural, Smallville, Stargate: SG-1"}
    And %{I press "Submit"}
end

Then /^I should see the tagset data$/ do
  Then %{I should see "Tag set was created successfully"}
    And %{I should see "My Tagset"}
    And %{I should see "Here's my tagset"}
    And %{I should see "tagsetter" within ".meta"}
    And %{I should see "Supernatural"}
end