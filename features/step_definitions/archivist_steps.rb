### GIVEN

Given /^I have an archivist "([^\"]*)"$/ do |name|
  Given %{I am logged in as "#{name}"}
    And %{I have loaded the "roles" fixture}
  When %{I am logged in as an admin}
      And %{I fill in "query" with "elynross"}
      And %{I press "Find"}
    When %{I check "user_roles_4"}
      And %{I press "Update"}
      And %{I follow "Log out"}
end

### WHEN

### THEN
