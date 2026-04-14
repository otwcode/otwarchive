When /^(?:|I )open help modal "([^"]*)"$/ do |link| # rubocop:disable Cucumber/RegexStepName
  Capybara.enable_aria_label = true
  step %{I follow "#{link}"}
end
