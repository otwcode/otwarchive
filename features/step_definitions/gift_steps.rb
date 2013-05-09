### THEN

Then /^"(.+)" should be notified by email about their gift "(.+)"$/ do |recipient, title|
  step %{1 email should be delivered to "#{recipient}"}
  step %{the email should contain "A gift story has been posted for you"}
  step %{the email should link to the "#{title}" work page}
end
