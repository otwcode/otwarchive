Given /^I set up importing$/ do
  step %{basic tags}
  step %{I am logged in as a random user}
  step %{I go to the import page}
end

When /^I start importing "(.*)"$/ do |url|
  step %{I set up importing}
  step %{I fill in "urls" with "#{url}"}
end

When /^I import "(.*)"$/ do |url|
  step %{I start importing "#{url}"}
  step %{I press "Import"}
end
  
When /^I import the urls$/ do |urls|
  step %{I set up importing}
  step %{I fill in "urls" with "#{urls}"}
  step %{I press "Import"}
end
