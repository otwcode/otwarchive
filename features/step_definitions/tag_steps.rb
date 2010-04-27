Given /^I have a canonical ([A-Z][^\"]*) tag named "([^\"]*)"$/ do |type, name|
  type.constantize.create(:name => name, :canonical => true)
end

Given /^I have a ([A-Z][^\"]*) tag named "([^\"]*)"$/ do |type, name|
  type.constantize.create(:name => name)
end
