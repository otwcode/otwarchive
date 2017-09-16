Given /^all search indexes are updated$/ do
  [Work, Bookmark, Pseud, Tag].each do |klass|
    klass.import
    klass.tire.index.refresh
  end
end

Given /^the (\w+) indexes are updated$/ do |model|
  model.classify.constantize.import
  model.classify.constantize.tire.index.refresh
end

