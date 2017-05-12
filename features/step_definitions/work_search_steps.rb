### GIVEN

### WHEN

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

When /^I search for works by "([^\"]*)"$/ do |creator|
  step %{I am on the homepage}
  step %{I fill in "site_search" with "creator: #{creator}"}
  step %{I press "Search"}
end

### THEN
