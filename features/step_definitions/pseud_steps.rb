### Given
Given /^I have pseud "([^"]*)"$/ do |pseud|
  Factory.create(:pseud, :name => pseud, :user => user)
end
### Then
Then /^I should have a default pseud of "([^"]*)"$/ do |pseud|
  user.reload.default_pseud.name.should == pseud
end
Then /^I should have pseud "([^"]*)"$/ do |pseud|
  user.pseuds.find_by_name(pseud).should be
end

