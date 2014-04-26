When /^I view the series "([^\"]*)"$/ do |series|
  visit series_url(Series.find_by_title!(series))
end

When /^I add the work "([^\"]*)" to series "([^\"]*)"(?: as "([^"]*)")?$/ do |work_title, series_title, pseud|
  work = Work.find_by_title(work_title)
  if work.blank?
    step "the draft \"#{work_title}\""
    work = Work.find_by_title(work_title)
    visit preview_work_url(work)
    click_button("Post")
    step "I should see \"Work was successfully posted.\""
  end

  if pseud.blank?
    step %{I create the pseud "#{pseud}"}
  end
  
  step "I edit the work \"#{work_title}\""

  unless pseud.nil?
    select(pseud, :from => "work_author_attributes_ids_")
  end
  
  check("series-options-show")  
  if Series.find_by_title(series_title)
    step %{I select "#{series_title}" from "work_series_attributes_id"}
  else
    fill_in("work_series_attributes_title", :with => series_title)
  end
  click_button("Post Without Preview")
end

When /^I add the work "([^\"]*)" to "(\d+)" series "([^\"]*)"$/ do |work_title, count, series_title|
  work = Work.find_by_title(work_title)
  if work.blank?
    step "the draft \"#{work_title}\""
    work = Work.find_by_title(work_title)
    visit preview_work_url(work)
    click_button("Post")
    step "I should see \"Work was successfully posted.\""
  end
  
  count.to_i.times do |i|
    step "I edit the work \"#{work_title}\""
    check("series-options-show")
    fill_in("work_series_attributes_title", :with => series_title + i.to_s)
    click_button("Post Without Preview")
  end
end
