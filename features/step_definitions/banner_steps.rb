### GIVEN

Given /^I have turned off the banner$/ do
  When "I turn off the banner"
end

### WHEN

When /^I turn off the banner$/ do
  Given %{I am logged in as "newname"}
  When %{I am on my user page}
  When %{I follow "Hide this banner"}
end

### THEN


