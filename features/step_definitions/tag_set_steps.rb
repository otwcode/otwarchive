
When /^I follow the add new tag ?set link$/ do
  Given %{I follow "New Tag Set"}
end

# This takes strings like:
# ...with the fandom tags "x, y, z" and the character tags "a, b, c"
When /^I set up the tag ?set "([^\"]*)" with (.*)$/ do |title, tags|
  Given %{I go to the new tag set page}
    And %{I fill in "Title" with "#{title}"}
    And %{I fill in "Brief Description" with "Here's my tagset"}
    tags.scan(/the (\w+) tags "([^\"]*)"/).each do |type, tags| 
      And %{I fill in "Add #{type.classify.pluralize}:" with "#{tags}"}
    end
    And %{I submit}
  Then %{I should see a create confirmation message}
end

When /^I add (.*) to the tag ?set "([^\"]*)"$/ do |tags, title|
  Given %{I go to the "#{title}" tag set edit page}
    tags.scan(/the (\w+) tags "([^\"]*)"/).each do |type, tags| 
      And %{I fill in "owned_tag_set_tag_set_attributes_fandom_tagnames_to_add" with "#{tags}"}
    end
    And %{I submit}
  Then %{I should see an update confirmation message}
end  

