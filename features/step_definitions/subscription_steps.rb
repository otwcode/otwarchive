When /^I view the "([^\"]*)" works index$/ do |tag|
  When %{I view the tag "#{tag}"}
end
