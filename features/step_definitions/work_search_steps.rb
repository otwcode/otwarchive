### GIVEN

### WHEN

When /^I search for a complex term from the search box$/ do
  step %{I am on the homepage}
      step %{I fill in "site_search" with "(title,summary): second words: >100"}
      step %{I press "Search"}
end

When /^I search for a simple term from the search box$/ do
  step %{I am on the homepage}
      step %{I fill in "site_search" with "first"}
      step %{I press "Search"}
end

When /^I search for works containing "([^\"]*)"$/ do |term|
  step %{I am on the homepage}
      step %{I fill in "site_search" with "#{term}"}
      step %{I press "Search"}
end

When /^I search for works by mod$/ do
  step %{I am on the homepage}
      step %{I fill in "site_search" with "author: mod"}
      step %{I press "Search"}
end

### THEN

Then /^I should see appropriate results for that complex term$/ do
  step %{I should see "Text: (title,summary): second"}
      step %{I should see "Words: >100"}
      step %{I should see "2 Found"}
      step %{I should not see "First work"}
      step %{I should see "second work"}
      step %{I should see "third work"}
      step %{I should not see "fourth"}
end
