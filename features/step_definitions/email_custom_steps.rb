Given /^(?:a clear email queue|no emails have been sent|the email queue is clear)$/ do
  reset_mailer
end

Then /^"([^\"]*)" should be emailed$/ do |user|
  @user = User.find_by(login: user)
  emails("to: \"#{email_for(@user.email)}\"").size.should > 0
end

Then /^"([^\"]*)" should not be emailed$/ do |user|
  @user = User.find_by(login: user)
  emails("to: \"#{email_for(@user.email)}\"").size.should == 0
end

Then /^the email to "([^\"]*)" should contain "([^\"]*)"$/ do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").first
  if email.multipart?
    email.text_part.body.should =~ /#{text}/
    email.html_part.body.should =~ /#{text}/
  else
    email.body.should =~ /#{text}/
  end
end

Then /^the email to "([^\"]*)" should not contain "([^\"]*)"$/ do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").first
  if email.multipart?
    email.text_part.body.should_not =~ /#{text}/
    email.html_part.body.should_not =~ /#{text}/
  else
    email.body.should_not =~ /#{text}/
  end
end

Then(/^"([^\"]*)" should receive (\d+) emails?$/) do |user, count|
  @user = User.find_by(login: user)
  emails("to: \"#{email_for(@user.email)}\"").size.should == count.to_i
end

Then /^the email should say what time it was sent$/ do
  # mailer time format: 11:38PM EDT Thu 29 September 2016
  nowish = Time.now.strftime('%I:%M%p %Z %a %d %B %Y')
  step %{the email should contain "Sent at #{nowish}"}
  step %{the email should not contain "sent_at"}
end
