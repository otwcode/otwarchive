Given /^(.*) first read "([^"]*)" on "([^"]*)"$/ do |login, title, date|
  user = User.find_by_login(login)
  work = Work.find_by_title(title)
  # create the reading
  reading = Reading.update_or_create(work, user)
  # backdate it (http://blog.evanweaver.com/articles/2006/12/26/hacking-activerecords-automatic-timestamps/)
  reading.class.record_timestamps = false
  reading.update_attribute(:updated_at, date)
  reading.update_attribute(:view_count, 1)
  reading.class.record_timestamps = true
end

