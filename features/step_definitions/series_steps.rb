When /^I view the series "([^\"]*)"$/ do |series|
  visit series_url(Series.find_by_title!(series))
end

When /^I add the work "([^\"]*)" to series "([^\"]*)"$/ do |work_title, series_title|
  work = Work.find_by_title(work_title)
  if work.blank?
    Given "the draft \"#{work_title}\""
    work = Work.find_by_title(work_title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
  When "I edit the work \"#{work_title}\""

  check("series-options-show")  
  if Series.find_by_title(series_title)
    And %{I select "#{series_title}" from "work_series_attributes_id"}
  else
    fill_in("work_series_attributes_title", :with => series_title)
  end
  click_button("Post without preview")
end

When /^I add the work "([^\"]*)" to "(\d+)" series "([^\"]*)"$/ do |work_title, count, series_title|
  work = Work.find_by_title(work_title)
  if work.blank?
    Given "the draft \"#{work_title}\""
    work = Work.find_by_title(work_title)
  end
  visit preview_work_url(work)
  click_button("Post")
  Then "I should see \"Work was successfully posted.\""
  
  count.to_i.times do |i|
    When "I edit the work \"#{work_title}\""
    check("series-options-show")
    fill_in("work_series_attributes_title", :with => series_title + i.to_s)
    click_button("Post without preview")
  end
end
