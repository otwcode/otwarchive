Then(/^(\d)+ emails? should be delivered to (.*)$/) do |count, to|
  emails("to: \"#{email_for(to)}\"").size.should == count.to_i
end

Then /^"([^\"]*)" should be emailed$/ do |user|
  @user = User.find_by_login(user)
  Then "show me the emails"
  emails("to: \"#{email_for(@user.email)}\"").size.should >= 1
end
