Given /^(.*) first read "([^"]*)" on "([^"]*)"$/ do |login, title, date|
  user = User.find_by(login: login)
  work = Work.find_by(title: title)
  time = date.to_time.in_time_zone("EST") + 1.day
  # create the reading
  reading_json = [user.id, time, work.id, work.major_version, work.minor_version, false].to_json
  Reading.reading_object(reading_json)
end

When /^the reading rake task is run$/ do
   Reading.update_or_create_in_database
end
