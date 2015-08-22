When /^I view the series "([^\"]*)"$/ do |series|
  visit series_url(Series.find_by_title!(series))
end

When /^I reorder the first two stories in the series "([^\"]*)"/ do |series|
  visit manage_series_url(Series.find_by_title(series))
  fill_in("serial_0", :with => "2")
  fill_in("serial_1", :with => "1")
  click_button("Update Positions")
end

When /^I add (?:the work )?"([^\"]*)" to (?:the )?series "([^\"]*)"(?: as "([^"]*)")?$/ do |work_title, series_title, pseud|
  if pseud.present?
    step %{I create the pseud "#{pseud}"}
  end

  work = Work.find_by_title(work_title)
  if work.blank?
    step %{I post the work "#{work_title}"}
  end  
  step "I edit the work \"#{work_title}\""
  unless pseud.nil?
    select(pseud, :from => "work_author_attributes_ids_")
  end
  
  step %{I add the series "#{series_title}"}
  click_button("Post Without Preview")
  step "I should see \"Work was successfully posted.\""
  Work.tire.index.refresh
end

When /^I add (?:the work )?"([^\"]*)" to (?:the )?"(\d+)" series "([^\"]*)"$/ do |work_title, count, series_title|
  work = Work.find_by_title(work_title)
  if work.blank?
    step %{I post the work "#{work_title}"}
  end
  
  count.to_i.times do |i|
    step "I edit the work \"#{work_title}\""
    check("series-options-show")
    fill_in("work_series_attributes_title", :with => series_title + i.to_s)
    click_button("Post Without Preview")
    step "I should see \"Work was successfully posted.\""
    Work.tire.index.refresh
  end
end

Then /^"([^\"]*)" should be part (\d+) of (?:the )?"([^\"]*)" series$/ do |work_title, part_num, series_title|
  work = Work.find_by_title(work_title)
  visit work_url(work)
  step %{I should see "Part #{part_num} of the #{series_title} series" within "div#series"}
  step %{I should see "Part #{part_num} of the #{series_title} series" within "dd.series"}
end
  
Then /^"([^\"]*)" should not be part of (?:the )?"([^\"]*)" series$/ do |work_title, series_title|
  work = Work.find_by_title(work_title)
  visit work_url(work)
  step %{I should not see "of the #{series_title} series"}
  series = Series.find_by_title(series_title)
  visit series_url(series)
  step %{I should not see "#{work_title}"}
end

Then /^the "([^\"]*)" series should belong to the pseud "([^\"]*)"$/ do |series_title, pseud_name|
  series = Series.find_by_title(series_title)
  visit series_url(series)
  step %{I should see "#{pseud_name}"}
end
