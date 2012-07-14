Given /^the (\w+) indexes are updated$/ do |model|
  model.classify.constantize.import
end

Given /^remote sphinx is stopped$/ do
end

Given /^sphinx is started again$/ do
end
