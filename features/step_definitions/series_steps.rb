When /^I view the series "([^\"]*)"$/ do |series|
  visit series_url(Series.find_by_title!(series))
end
