### GIVEN

Given /^a set of alternate universe works for searching$/ do
  step %{basic tags}

  # Create a metatag with a syn
  step %{a canonical freeform "Alternate Universe"}
  step %{a synonym "AU" of the tag "Alternate Universe"}

  # Create a subtag with a syn
  step %{a canonical freeform "Alternate Universe - High School"}
  step %{a synonym "High School AU" of the tag "Alternate Universe - High School"}

  # Create another subtag
  step %{a canonical freeform "Alternate Universe - Coffee Shops & Cafés"}

  # Set up the tree
  step %{"Alternate Universe" is a metatag of the freeform "Alternate Universe - High School"}
  step %{"Alternate Universe" is a metatag of the freeform "Alternate Universe - Coffee Shops & Cafés"}

  # Create an unwrangled tag
  step %{a noncanonical freeform "Coffee Shop AU"}

  # Create a work for every tag except Alternate Universe - High School
  ["Alternate Universe", "AU", "High School AU", "Alternate Universe - Coffee Shops & Cafés", "Coffee Shop AU"].each do |freeform|
    FactoryGirl.create(:posted_work, freeform_string: freeform)
  end

  step %{the work indexes are updated}
end

Given /^a set of Spock works for searching$/ do
  step %{basic tags}

  # Create three fandoms
  step %{a canonical fandom "Star Trek: TOS"}
  step %{a canonical fandom "Star Trek: AOS"}
  step %{a canonical fandom "Star Trek: TNG"}

  # Create a charcater
  step %{a canonical character "Spock"}

  # Create a work for the character in each fandom
  ["Star Trek: TOS", "Star Trek: AOS", "Star Trek: TNG"].each do |fandom|
    FactoryGirl.create(:posted_work,
                      fandom_strong: fandom,
                      character_string: "Spock")
  end

  step %{the work indexes are updated}
end

Given /^a set of Kirk\/Spock works for searching$/ do
  step %{basic tags}

  # Create a relationship with two syns
  step %{a canonical relationship "James T. Kirk/Spock"}
  step %{a synonym "K/S" of the tag "James T. Kirk/Spock"}
  step %{a synonym "Spirk" of the tag "James T. Kirk/Spock"}

  # Create a work for each tag
  ["James T. Kirk/Spock", "K/S", "Spirk"].each do |relationship|
    FactoryGirl.create(:posted_work, relationship_string: relationship)
  end

  # Create a F/M work using one of the synonyms
  FactoryGirl.create(:posted_work,
                     title: "The Genderswap K/S Work That Uses a Synonym",
                     relationship_string: "Spirk",
                     category_string: "F/M")

  step %{the work indexes are updated}
end

Given /^a set of Spock\/Uhura works for searching$/ do
  step %{basic tags}

  # Create a two-character relationship
  step %{a canonical relationship "Spock/Nyota Uhura"}

  # Create a threesome with a name that is a partial match for the relationship
  step %{a canonical relationship "James T. Kirk/Spock/Nyota Uhura"}

  # Create a work for the pairing tag
  FactoryGirl.create(:posted_work, relationship_string: "Spock/Nyota Uhura")

  # Create a work for the threesome tag
  FactoryGirl.create(:posted_work,
                     relationship_string: "James T. Kirk/Spock/Nyota Uhura")

  step %{the work indexes are updated}
end

### WHEN

When /^I search for a simple term from the search box$/ do
  step %{I am on the homepage}
      step %{I fill in "site_search" with "first"}
      step %{I press "Search"}
end

When /^I search for works containing "([^"]*)"$/ do |term|
  step %{I am on the homepage}
      step %{I fill in "site_search" with "#{term}"}
      step %{I press "Search"}
end

When /^I search for works by "([^"]*)"$/ do |creator|
  step %{I am on the homepage}
  step %{I fill in "site_search" with "creator: #{creator}"}
  step %{I press "Search"}
end

### THEN

Then /^the ([\d]+)(?:st|nd|rd|th) result should contain "([^"]*)"$/ do |n, text|
  selector = "ol.work > li:nth-of-type(#{n})"
  with_scope(selector) do
    page.should have_content(text)
  end
end
