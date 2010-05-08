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

