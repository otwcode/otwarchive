Then /^"([^\"]*)" should be emailed$/ do |user|
  @user = User.find_by_login(user)
  emails("to: \"#{email_for(@user.email)}\"").size.should >= 1
end
