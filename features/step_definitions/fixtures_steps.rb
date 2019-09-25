Given /^I have loaded the fixtures$/ do
  ActiveRecord::FixtureSet.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  ActiveRecord::FixtureSet.create_fixtures(fixtures_folder, fixtures)
  step %{all search indexes are completely regenerated}
end

Given /^I have loaded the "([^\"]*)" fixture$/ do |fixture|
  ActiveRecord::FixtureSet.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  ActiveRecord::FixtureSet.create_fixtures(fixtures_folder, [fixture])
end
