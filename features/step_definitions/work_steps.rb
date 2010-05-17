When /^I view the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
end

When /^I edit the work "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  click_link("Edit")
end

Then /^(?:|I )should see work "([^\"]*)" with tags "([^\"]*)"$/ do |regexp, tags|
  regexp = Regexp.new(regexp)
  if defined?(Spec::Rails::Matchers)
    response.should contain(regexp)
  else
    assert_match(regexp, response_body)
  end
end

When /^I edit the bookmark for "([^\"]*)"$/ do |work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  click_link("Edit/Add Bookmark")
end

When /^I post the work "([^\"]*)"$/ do |title|
  visit path_to("the new work page")
  select("Not Rated", :from => "Rating")
  check("No Archive Warnings Apply")
  fill_in("Fandoms", :with => "Stargate SG-1")
  fill_in("Work Title", :with => title)
  fill_in("content", :with => "That could be an amusing crossover.")
  click_button("Preview")
  click_button("Post")
end
