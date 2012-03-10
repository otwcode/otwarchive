### GIVEN

### WHEN

When /^I search for a complex term from the search box$/ do
  When %{I am on the homepage}
      And %{I fill in "site_search" with "(title,summary): second words: >100"}
      And %{I press "search"}
end

When /^I search for a simple term from the search box$/ do
  When %{I am on the homepage}
      And %{I fill in "site_search" with "first"}
      And %{I press "search"}
end

When /^I search for works containing "([^\"]*)"$/ do |term|
  When %{I am on the homepage}
      And %{I fill in "site_search" with "#{term}"}
      And %{I press "search"}
end

When /^I search for works by mod$/ do
  When %{I am on the homepage}
      And %{I fill in "site_search" with "author: mod"}
      And %{I press "search"}
end

### THEN

Then /^I should see appropriate results for that complex term$/ do
  Then %{I should see "Text: (title,summary): second"}
      And %{I should see "Words: >100"}
      And %{I should see "2 Found"}
      And %{I should not see "First work"}
      And %{I should see "second work"}
      And %{I should see "third work"}
      And %{I should not see "fourth"}
end
