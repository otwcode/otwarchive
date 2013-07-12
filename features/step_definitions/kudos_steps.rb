### GIVEN

### WHEN

When /^I leave kudos on "([^\"]*)"$/ do |work_title|
  step %{I view the work "#{work_title}"}
  click_button("kudo_submit")
end

### THEN

Then /^I should see kudos on every chapter$/ do
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Entire Work"}
  step %{I should see "myname3 left kudos on this work!"}
end

Then /^I should see kudos on every chapter but the draft$/ do
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should not see "myname3 left kudos on this work!"}
  step %{I follow "Entire Work"}
  step %{I should see "myname3 left kudos on this work!"}
end
