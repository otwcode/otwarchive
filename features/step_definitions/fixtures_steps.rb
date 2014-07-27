Given /^I have loaded the fixtures$/ do 
  ActiveRecord::Fixtures.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  ActiveRecord::Fixtures.create_fixtures(fixtures_folder, fixtures)
  step %{all search indexes are updated}
end

Given /^I have loaded the "([^\"]*)" fixture$/ do |fixture|
  ActiveRecord::Fixtures.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  ActiveRecord::Fixtures.create_fixtures(fixtures_folder, [fixture])
end
