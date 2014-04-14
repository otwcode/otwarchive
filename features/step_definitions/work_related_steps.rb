### GIVEN

Given /^I have related works setup$/ do
  step %{I am logged in as "inspiration"}
  step %{I am logged in as "translator"}
  step %{I am logged in as "remixer"}
    step "basic tags"
    step "all emails have been delivered"
    step %{I have loaded the "languages" fixture}
    step %{I am logged in as "inspiration"}
    step %{I post the work "Worldbuilding"}
    step %{I post the work "Worldbuilding Two"}
    step "I am logged out"
end

Given /^a translation has been posted$/ do
  step "I post a translation"
end

Given /^a remix has been posted$/ do
  step "I post a related work"
end

### WHEN

When /^I post a related work$/ do
  step %{I am logged in as "remixer"}
    step %{I go to the new work page}
    step %{I select "Not Rated" from "Rating"}
    step %{I check "No Archive Warnings Apply"}
    step %{I fill in "Fandoms" with "Stargate"}
    step %{I fill in "Work Title" with "Followup"}
    step %{I fill in "content" with "That could be an amusing crossover."}
    step %{I list the work "Worldbuilding" as inspiration}
    step %{I press "Preview"}
  step %{I press "Post"}
end

When /^I post a translation$/ do
  step %{I am logged in as "translator"}
    step %{I draft a translation}
  step %{I press "Post"}
end

When /^I post a translation of my own work$/ do
  step %{I am logged in as "inspiration"}
    step %{I draft a translation}
  step %{I press "Post"}
end

When /^I draft a translation$/ do
  step %{I go to the new work page}
    step %{I fill in "Fandoms" with "Stargate"}
    step %{I fill in "Work Title" with "Worldbuilding Translated"}
    step %{I fill in "content" with "That could be an amusing crossover."}
    step %{I list the work "Worldbuilding" as inspiration}
    step %{I check "This is a translation"}
    step %{I select "Deutsch" from "Choose a language"}
    step %{I press "Preview"}
end

When /^I approve a related work$/ do
  step %{I am logged in as "inspiration"}
    step "I am on my user page"
  step %{I follow "Related Works"}
  step %{I follow "Approve"}
  step %{I press "Yes, link me!"}
end

When /^I view my related works$/ do
  step "I go to my user page"
    step %{I follow "Related Works"}
end

### THEN

Then /^a related work should be seen$/ do
  step %{I should see "Work was successfully posted"}
    step %{I should see "Inspired by Worldbuilding by inspiration"}
end

Then /^the original author should be emailed$/ do
  step "1 email should be delivered"
end

Then /^approving the related work should succeed$/ do
  step %{I should see "Link was successfully approved"}
end
