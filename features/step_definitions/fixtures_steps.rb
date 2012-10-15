Given /^I have loaded the fixtures$/ do 
  Fixtures.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  Fixtures.create_fixtures(fixtures_folder, fixtures)

  And %{all search indexes are updated}
end

Given /^I have loaded the "([^\"]*)" fixture$/ do |fixture|
  Fixtures.reset_cache
  fixtures_folder = File.join(Rails.root, 'features', 'fixtures')
  Fixtures.create_fixtures(fixtures_folder, [fixture])
end
