When /^I view the "([^\"]*)" works index$/ do |tag|
  When %{I view the tag "#{tag}"}
  When %{I follow "filter works"}
  Then "show me the page"
end
