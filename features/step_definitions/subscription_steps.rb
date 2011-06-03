When /^I view the "([^\"]*)" works index$/ do |tag|
  When %{I view the tag "#{tag}"}
  Then "show me the content"
  When %{I follow "filter works"}
  Then "show me the page"
end
