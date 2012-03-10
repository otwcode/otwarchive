### GIVEN

Given /^I have related works setup$/ do
  Given %{I am logged in as "inspiration"}
  Given %{I am logged in as "translator"}
  Given %{I am logged in as "remixer"}
    And "basic tags"
    And "all emails have been delivered"
    And %{I have loaded the "languages" fixture}
    And %{I am logged in as "inspiration"}
    And %{I post the work "Worldbuilding"}
    And %{I post the work "Worldbuilding Two"}
    And "I am logged out"
end

Given /^a translation has been posted$/ do
  When "I post a translation"
end

Given /^a remix has been posted$/ do
  When "I post a related work"
end

### WHEN

When /^I post a related work$/ do
  When %{I am logged in as "remixer"}
    And %{I go to the new work page}
    And %{I select "Not Rated" from "Rating"}
    And %{I check "No Archive Warnings Apply"}
    And %{I fill in "Fandoms" with "Stargate"}
    And %{I fill in "Work Title" with "Followup"}
    And %{I fill in "content" with "That could be an amusing crossover."}
    And %{I list the work "Worldbuilding" as inspiration}
    And %{I press "Preview"}
  When %{I press "Post"}
end

When /^I post a translation$/ do
  When %{I am logged in as "translator"}
    And %{I draft a translation}
  When %{I press "Post"}
end

When /^I post a translation of my own work$/ do
  When %{I am logged in as "inspiration"}
    And %{I draft a translation}
  When %{I press "Post"}
end

When /^I draft a translation$/ do
  When %{I go to the new work page}
    And %{I fill in "Fandoms" with "Stargate"}
    And %{I fill in "Work Title" with "Worldbuilding Translated"}
    And %{I fill in "content" with "That could be an amusing crossover."}
    And %{I list the work "Worldbuilding" as inspiration}
    And %{I check "This is a translation"}
    And %{I select "Deutsch" from "Choose a language"}
    And %{I press "Preview"}
end

When /^I approve a related work$/ do
  When %{I am logged in as "inspiration"}
    And "I am on my user page"
  When %{I follow "Related Works"}
  When %{I follow "Approve"}
  When %{I press "Yes, link me!"}
end

When /^I view my related works$/ do
  When "I go to my user page"
    And %{I follow "Related Works"}
end

### THEN

Then /^a related work should be seen$/ do
  Then %{I should see "Work was successfully posted"}
    And %{I should see "Inspired by Worldbuilding by inspiration"}
end

Then /^the original author should be emailed$/ do
  Then "1 email should be delivered"
end

Then /^approving the related work should succeed$/ do
  Then %{I should see "Link was successfully approved"}
end
