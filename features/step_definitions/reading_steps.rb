Given /^(.*) first read "([^"]*)" on "([^"]*)"$/ do |login, title, date|
  user = User.find_by(login: login)
  work = Work.find_by(title: title)
  time = date.to_time.in_time_zone("UTC")
  # create the reading
  reading_json = [user.id, time, work.id, work.major_version, work.minor_version, false].to_json
  Reading.reading_object(reading_json)
end

When /^the reading rake task is run$/ do
  step %{I run the rake task "readings:to_database"}
end
