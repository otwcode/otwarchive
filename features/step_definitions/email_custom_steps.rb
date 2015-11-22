Then /^"([^\"]*)" should be emailed$/ do |user|
  @user = User.find_by_login(user)
  emails("to: \"#{email_for(@user.email)}\"").size.should > 0
end

Then /^"([^\"]*)" should not be emailed$/ do |user|
  @user = User.find_by_login(user)
  emails("to: \"#{email_for(@user.email)}\"").size.should == 0
end

Then(/^"([^\"]*)" should receive (\d+) emails?$/) do |user, count|
  @user = User.find_by_login(user)
  emails("to: \"#{email_for(@user.email)}\"").size.should == count.to_i
end
  