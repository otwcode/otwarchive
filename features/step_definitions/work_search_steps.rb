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

Given /^a set of Steve Rogers works for searching$/ do
  step %{basic tags}

  # Create two fandoms
  step %{a canonical fandom "Marvel Cinematic Universe"}
  step %{a canonical fandom "The Avengers (Marvel Movies)"}

  # Create a character with a syn
  step %{a canonical character "Steve Rogers"}
  step %{a synonym "Captain America" of the tag "Steve Rogers"}

  # Create a work for each character tag in each fandom
  ["Marvel Cinematic Universe", "The Avengers (Marvel Movies)"].each do |fandom|
    ["Steve Rogers", "Captain America"].each do |character|
    FactoryGirl.create(:posted_work,
                       fandom_string: fandom,
                       character_string: character)
    end
  end

  # Create a work without Steve as a character but with him in a relationship
  FactoryGirl.create(:posted_work,
                     relationship_string: "Steve Rogers/Tony Stark")

  # Create a work that only mentions Steve in the summary
  FactoryGirl.create(:posted_work,
                     summary: "Bucky thinks about his pal Steve Rogers.")

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

  # Create a canonical two-character relationship with a syn
  step %{a canonical relationship "Spock/Nyota Uhura"}
  step %{a synonym "Uhura/Spock" of the tag "Spock/Nyota Uhura"}

  # Create a threesome with a name that is a partial match for the relationship
  step %{a canonical relationship "James T. Kirk/Spock/Nyota Uhura"}

  # Create a work for each tag
  ["Spock/Nyota Uhura", "Uhura/Spock", "James T. Kirk/Spock/Nyota Uhura"].each do |relationship|
    FactoryGirl.create(:posted_work,
                       relationship_string: relationship)
  end

  step %{the work indexes are updated}
end

Given /^a set of works with various categories for searching$/ do
  step %{basic tags}

  # Create one work with each category
  %w(Gen Other F/F Multi F/M M/M).each do |category|
    FactoryGirl.create(:posted_work, category_string: category)
  end

  # Create one work using multiple categories
  FactoryGirl.create(:posted_work, category_string: "M/M, F/F")

  step %{the work indexes are updated}
end

Given /^a set of works with comments for searching$/ do
  step %{basic tags}

  # Comments created with factories are not added to a work's stat totals
  # even after running the rake task, so we're doing it through steps that add
  # comments through the interface
  step %{I have a work "Work 1"}
  step %{the work "Work 2" with 1 comments setup}
  step %{the work "Work 3" with 1 comments setup}
  step %{the work "Work 4" with 1 comments setup}
  step %{the work "Work 5" with 3 comments setup}
  step %{the work "Work 6" with 3 comments setup}
  step %{the work "Work 7" with 10 comments setup}

  step %{the statistics_tasks rake task is run}
  step %{the work indexes are updated}
end

Given /^a set of Star Trek works for searching$/ do
  step %{basic tags}

  # Create three related canonical fandoms
  step %{a canonical fandom "Star Trek"}
  step %{a canonical fandom "Star Trek: The Original Series"}
  step %{a canonical fandom "Star Trek: The Original Series (Movies)"}

  # Create a syn for one of the fandoms
  step %{a synonym "ST: TOS" of the tag "Star Trek: The Original Series"}

  # Create an unrelated fourth fandom we'll use for a crossover
  step %{a canonical fandom "Battlestar Galactica (2003)"}

  # Set up the tree for the related fandoms
  step %{"Star Trek" is a metatag of the fandom "Star Trek: The Original Series"}
  step %{"Star Trek: The Original Series" is a metatag of the fandom "Star Trek: The Original Series (Movies)"}

  # Create a work using each of the related fandoms
  ["Star Trek", "Star Trek: The Original Series", "Star Trek: The Original Series (Movies)", "ST: TOS"].each do |fandom|
    FactoryGirl.create(:posted_work, fandom_string: fandom)
  end

  # Create a work with two fandoms (e.g. a crossover)
  FactoryGirl.create(:posted_work,
                     fandom_string: "ST: TOS,
                                    Battlestar Galactica (2003)")

  # Create a work with an additional tag (freeform) that references the fandom
  FactoryGirl.create(:posted_work,
                     fandom_string: "Battlestar Galactica (2003)",
                     freeform_string: "Star Trek Fusion")

  step %{the work indexes are updated}
end

Given /^a set of works with bookmarks for searching$/ do
  step %{basic tags}

  # Bookmarks created with factories are not added to a work's stat totals
  # even after running the rake task, so we're doing it through steps that add
  # bookmarks through the interface
  step %{I have a work "Work 1"}
  step %{the work "Work 2" with 1 bookmark setup}
  step %{the work "Work 3" with 1 bookmark setup}
  step %{the work "Work 4" with 2 bookmarks setup}
  step %{the work "Work 5" with 2 bookmarks setup}
  step %{the work "Work 6" with 4 bookmarks setup}
  step %{the work "Work 7" with 10 bookmarks setup}

  step %{the statistics_tasks rake task is run}
  step %{the work indexes are updated}
end

Given /^a set of works with various ratings for searching$/ do
  step %{basic tags}

  ratings = [ArchiveConfig.RATING_DEFAULT_TAG_NAME,
             ArchiveConfig.RATING_GENERAL_TAG_NAME,
             ArchiveConfig.RATING_TEEN_TAG_NAME,
             ArchiveConfig.RATING_MATURE_TAG_NAME,
             ArchiveConfig.RATING_EXPLICIT_TAG_NAME]

  ratings.each do |rating|
    FactoryGirl.create(:posted_work, rating_string: rating)
  end

  FactoryGirl.create(:posted_work,
                     rating_string: ArchiveConfig.RATING_DEFAULT_TAG_NAME,
                     summary: "Nothing explicit here.")

  step %{the work indexes are updated}
end

Given /^a set of works with various warnings for searching$/ do
  step %{basic tags}
  step %{all warnings exist}

  warnings = [ArchiveConfig.WARNING_DEFAULT_TAG_NAME,
              ArchiveConfig.WARNING_NONE_TAG_NAME,
              ArchiveConfig.WARNING_VIOLENCE_TAG_NAME,
              ArchiveConfig.WARNING_DEATH_TAG_NAME,
              ArchiveConfig.WARNING_NONCON_TAG_NAME,
              ArchiveConfig.WARNING_CHAN_TAG_NAME]

  # Create a work for each warning
  warnings.each do |warning|
    FactoryGirl.create(:posted_work, warning_string: warning)
  end

  # Create a work that uses multiple warnings
  FactoryGirl.create(:posted_work,
                     warning_string: "#{ArchiveConfig.WARNING_DEFAULT_TAG_NAME},
                                     #{ArchiveConfig.WARNING_NONE_TAG_NAME}")

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

When /^I search for works without the "([^"]*)"(?: and "([^"]*)")? filter_ids?$/ do |tag_1, tag_2|
  filter_id_1 = Tag.find_by_name(tag_1).filter_taggings.first.filter_id
  filter_id_2 = Tag.find_by_name(tag_2).filter_taggings.first.filter_id if tag_2
  step %{I am on the homepage}
  if tag_2
    fill_in("site_search", with: "-filter_ids: #{filter_id_1} -filter_ids: #{filter_id_2}")
  else
    fill_in("site_search", with: "-filter_ids: #{filter_id_1}")
  end
  step %{I press "Search"}
end

When /^I exclude the tags? "([^"]*)"(?: and "([^"]*)")? by filter_id( from the search box)?$/ do |tag_1, tag_2|
  filter_id_1 = Tag.find_by_name(tag_1).filter_taggings.first.filter_id
  filter_id_2 = Tag.find_by_name(tag_2).filter_taggings.first.filter_id if tag_2
  if tag_2
    fill_in("work_search_query", with: "-filter_ids: #{filter_id_1} -filter_ids: #{filter_id_2}")
  else
    fill_in("work_search_query", with: "-filter_ids: #{filter_id_1}")
  end
end

### THEN

Then /^the results should contain the category "([^"]*)"$/ do |category|
  expect(page).to have_css("ol.work .required-tags .category", text: category)
end

Then /^the results should not contain the category "([^"]*)"$/ do |category|
  expect(page).not_to have_css("ol.work .required-tags .category", text: category)
end

Then /^the results should contain the ([^"]*) tag "([^"]*)"$/ do |type, tag|
  selector = if type == "fandom"
               "ol.work .fandoms"
             elsif type == "rating" || type == "category"
               "ol.work .required-tags .#{type}"
             else
               "ol.work .tags .#{type.pluralize}"
             end
  expect(page).to have_css(selector, text: tag)
end

Then /^the results should not contain the ([^"]*) tag "([^"]*)"$/ do |type, tag|
  expect(page).not_to have_css("ol.work .tags .#{type.pluralize}", text: tag)
end

Then /^the results should contain a summary mentioning "([^"]*)"$/ do |term|
  expect(page).to have_css("ol.work .summary", text: term)
end

Then /^the results should not contain a summary mentioning "([^"]*)"$/ do |term|
  expect(page).not_to have_css("ol.work .summary", text: term)
end

Then /^the ([\d]+)(?:st|nd|rd|th) result should contain "([^"]*)"$/ do |n, text|
  selector = "ol.work > li:nth-of-type(#{n})"
  with_scope(selector) do
    page.should have_content(text)
  end
end

# If JavaScript is enabled and we want to check that information is retained
# when editing a search, we can't look at what is in the input -- we have to
# look at the contents of the ul that contains both the field and the added tags
Then /^"([^"]*)" should already be entered in the work search ([^"]*) autocomplete field$/ do |tag, field|
  within(:xpath, "//input[@id=\"work_search_#{field.singularize}_names_autocomplete\"]/parent::li/parent::ul") do
    page.should have_content(tag)
  end
end

Then /^the search summary should include the filter_id for "([^"]*)"$/ do |tag|
  filter_id = Tag.find_by_name(tag).filter_taggings.first.filter_id
  step %{I should see "filter_ids: #{filter_id}" within "#main h4.heading"}
end
