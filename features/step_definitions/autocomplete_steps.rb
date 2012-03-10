
Given /^a set of tags for testing autocomplete$/ do
  Given %{a canonical fandom "Supernatural"}
    And %{a canonical fandom "Battlestar Galactica"}
    And %{a noncanonical fandom "Super Awesome"}
    And %{a canonical character "Ellen Harvelle" in fandom "Supernatural"}
    And %{a canonical character "Ellen Tigh" in fandom "Battlestar Galactica"}
    And %{a noncanonical character "ellen somebody"}
    And %{a canonical relationship "Dean/Castiel" in fandom "Supernatural"}
    And %{a canonical relationship "Sam/Dean" in fandom "Supernatural"}
    And %{a canonical relationship "Ellen Tigh/Lee Adama" in fandom "Battlestar Galactica"}
    And %{a noncanonical relationship "Destiel"}
    And %{a canonical freeform "Alternate Universe"}
    And %{a canonical freeform "Superduper"}
    And %{a noncanonical freeform "alternate sundays"}
end

Then /^I should see "([^\"]+)" in the autocomplete$/ do |string|
  Then %{I should find "#{string}" within ".autocomplete"}
end

Then /^I should not see "([^\"]+)" in the autocomplete$/ do |string|
  Then %{I should not find "#{string.gsub(/\'/, '\'')}" within ".autocomplete"}
end

# this is needed for values like 'Allo 'Allo that can't be handled right 
# by Nokogiri in the typical find
# note: this might only work for the first autocomplete in a page D:
Then /^the autocomplete value should be set to "([^"]*)"$/ do |string|
  string == page.find("input.autocomplete").node['value']
end

# Define all values to be entered here depending on the fieldname
When /^I enter text in the "([^\"]+)" autocomplete field$/ do |fieldname|
  text = case fieldname
    when "Fandoms"
      "sup"
    when "Additional Tags"
      "alt"
    when "Characters"
      "ellen"
    when "Relationships"
      "stiel"
    when "Your Tags"
      "sup"
    else
      ""
    end
  When %{I fill in "#{fieldname}" with "#{text}"}
end

# alias for most common fields
When /^I enter text in the (\w+) autocomplete field$/ do |fieldtype|
  fieldname = case fieldtype
    when 'fandom'
      "Fandoms"
    when 'character'
      "Characters"
    when 'relationship'
      "Relationships"
    when 'freeform'
      "Additional Tags"
    end
  When %{I enter text in the "#{fieldname}" autocomplete field}
end

When /^I specify a fandom and enter text in the character autocomplete field$/ do
  When %{I fill in "Fandoms" with "Supernatural"}
    And %{I enter text in the character autocomplete field}
end

When /^I specify a fandom and enter text in the relationship autocomplete field$/ do
  When %{I fill in "Fandoms" with "Supernatural"}
    And %{I enter text in the relationship autocomplete field}
end

When /^I specify two fandoms and enter text in the character autocomplete field$/ do
  When %{I fill in "Fandoms" with "Supernatural, Battlestar Galactica"}
    And %{I enter text in the "Characters" autocomplete field}
end

## Here's where we create the steps defining which tags should appear/not appear 
## based on the set of tags and the data entered

Then /^I should only see matching canonical fandom tags in the autocomplete$/ do
  Then %{I should see "Supernatural" in the autocomplete}
	  And %{I should not see "Super Awesome" in the autocomplete}
	  And %{I should not see "Battlestar Galactica" in the autocomplete}
	  And %{I should not see "Superduper" in the autocomplete}
end
  
Then /^I should only see matching canonical freeform tags in the autocomplete$/ do
  Then %{I should see "Alternate Universe" in the autocomplete}
    And %{I should not see "alternate sundays" in the autocomplete}
    And %{I should not see "Superduper" in the autocomplete}
end

Then /^I should only see matching canonical character tags in the autocomplete$/ do
  Then %{I should see "Ellen Harvelle" in the autocomplete}
  	And %{I should see "Ellen Tigh" in the autocomplete}
  	And %{I should not see "Ellen Somebody" in the autocomplete}
end

Then /^I should only see matching canonical relationship tags in the autocomplete$/ do
  Then %{I should see "Dean/Castiel" in the autocomplete}
  	And %{I should not see "Sam/Dean" in the autocomplete}
  	And %{I should not see "Destiel" in the autocomplete}
end


Then /^I should only see matching canonical character tags in the specified fandom in the autocomplete$/ do
  Then %{I should see "Ellen Harvelle" in the autocomplete}
  	And %{I should not see "Ellen Tigh" in the autocomplete}
  	And %{I should not see "Ellen Somebody" in the autocomplete}
end

Then /^I should see matching canonical character tags from both fandoms in the autocomplete$/ do
  Then %{I should see "Ellen Harvelle" in the autocomplete}
  	And %{I should see "Ellen Tigh" in the autocomplete}
  	And %{I should not see "Ellen Somebody" in the autocomplete}
end

Then /^I should only see matching canonical relationship tags in the specified fandom in the autocomplete$/ do
  Then %{I should see "Dean/Castiel" in the autocomplete}
  	And %{I should not see "Destiel" in the autocomplete}
end

Then /^I should only see matching canonical tags in the autocomplete$/ do
  Then %{I should see "Supernatural" in the autocomplete}
    And %{I should see "Superduper" in the autocomplete}
    And %{I should not see "Dean/Castiel" in the autocomplete}
end

Then /^I should only see matching noncanonical tags in the autocomplete$/ do
  Then %{I should see "Super Awesome" in the autocomplete}
    And %{I should not see "Supernatural" in the autocomplete}
end

Then /^the tag autocomplete fields should list only matching canonical tags$/ do
	When %{I enter text in the fandom autocomplete field}
	Then %{I should only see matching canonical fandom tags in the autocomplete}
	When %{I enter text in the character autocomplete field}
	Then %{I should only see matching canonical character tags in the autocomplete}
	When %{I enter text in the relationship autocomplete field}
	Then %{I should only see matching canonical relationship tags in the autocomplete}
	if page.find("Additional Tags")
	  puts "Testing freeform field"
	  When %{I enter text in the freeform autocomplete field}
	  Then %{I should only see matching canonical freeform tags in the autocomplete}
	end
end

Then /^the fandom-specific tag autocomplete fields should list only fandom-specific canonical tags$/ do
	When %{I specify a fandom and enter text in the character autocomplete field}
	Then %{I should only see matching canonical character tags in the specified fandom in the autocomplete}
	When %{I specify a fandom and enter text in the relationship autocomplete field}
	Then %{I should only see matching canonical relationship tags in the specified fandom in the autocomplete}
	When %{I specify two fandoms and enter text in the character autocomplete field}
	Then %{I should see matching canonical character tags from both fandoms in the autocomplete}
end

Then /^the external url autocomplete field should list the urls of existing external works$/ do
  fill_in("URL", :with => "zoo")
  Then %{I should see "zooey-glass.dreamwidth.org" in the autocomplete}
  And %{I should not see "parenthetical.livejournal.com" in the autocomplete}
end


Given /^a set of users for testing autocomplete$/ do
  %w(myname coauthor giftee).each do |username|
    user = Factory.create(:user, {:login => username, :password => DEFAULT_PASSWORD})
    user.activate
  end
end

Then /^the coauthor autocomplete field should list matching users$/ do
  check("Add co-authors?")
  fill_in("pseud_byline", :with => "coa")
  Then %{I should see "coauthor" in the autocomplete}
  Then %{I should not see "giftee" in the autocomplete}
end

Then /^the gift recipient autocomplete field should list matching users$/ do
  fill_in("work_recipients", :with => "gif")
  Then %{I should see "giftee" in the autocomplete}
  Then %{I should not see "coauthor" in the autocomplete}
end

Given /^a set of collections for testing autocomplete$/ do
  Given %{I create the collection "awesome"}
  Given %{I create the collection "great"}
  Given %{I create the collection "really great"}
end

Then /^the collection item autocomplete field should list matching collections$/ do
  fill_in("work_collection_names", :with => "gre")
  Then %{I should see "great" in the autocomplete}
  And %{I should see "really great" in the autocomplete}
  And %{I should not see "awesome" in the autocomplete}
end

Given /^a gift exchange for testing autocomplete$/ do
	Given %{I have created the gift exchange "autocomplete"}
end

When /^I edit the gift exchange for testing autocomplete$/ do
  visit(edit_collection_gift_exchange_path(Collection.find_by_name("autocomplete")))
end

When /^I submit values in the tag autocomplete fields$/ do
  fill_in("Fandoms", :with => "Supernatural, Smallville")
  fill_in("Characters", :with => "Clark Kent, Lex Luthor, Dean Winchester")
  When %{I submit}
end

Then /^the tag autocomplete fields should have the entered values$/ do 
  Then %{I should see "Supernatural" in the autocomplete}
    And %{I should see "Smallville" in the autocomplete}
    And %{I should see "Clark Kent" in the autocomplete}
    And %{I should see "Lex Luthor" in the autocomplete}
    And %{I should see "Dean Winchester" in the autocomplete}
end
