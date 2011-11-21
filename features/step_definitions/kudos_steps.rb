### GIVEN

### WHEN

### THEN

Then /^I should see kudos on every chapter$/ do
  Then %{I should see "myname3 left kudos on this work!"}
  When %{I follow "Next Chapter"}
  Then %{I should see "myname3 left kudos on this work!"}
  When %{I follow "Entire Work"}
  Then %{I should see "myname3 left kudos on this work!"}
end

Then /^I should see kudos on every chapter but the draft$/ do
  Then %{I should see "myname3 left kudos on this work!"}
  When %{I follow "Next Chapter"}
  Then %{I should see "myname3 left kudos on this work!"}
  When %{I follow "Next Chapter"}
  Then %{I should not see "myname3 left kudos on this work!"}
  When %{I follow "Entire Work"}
  Then %{I should see "myname3 left kudos on this work!"}
end
