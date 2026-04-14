When /^I view the "([^\"]*)" works index$/ do |tag|
  visit works_path(tag_id: tag.to_param)
end

When /^I view the "([^"]*)" works feed$/ do |tag|
  visit "/tags/#{Tag.find_by_name(tag).id}/feed.atom"
end

When /^"([^\"]*)" subscribes to (author|work|series) "([^\"]*)"$/ do |user, type, name|
  case type
  when "author"
    step %{the user "#{name}" exists and is activated}
    step %{I am logged in as "#{user}"}
    step %{I go to #{name}'s user page}
  when "work"
    unless Work.find_by(title: name)
      step %{I am logged in as "wip_author"}
      step %{I post the work "#{name}"}
    end
    step %{I am logged in as "#{user}"}
    visit work_url(Work.find_by(title: name))
  when "series"
    unless Series.find_by(title: name)
      step %{I am logged in as "series_author"}
      step %{I add the work "Blah" to series "#{name}"}
    end
    step %{I am logged in as "#{user}"}
    step %{I view the series "#{name}"}
  end
  step %{I press "Subscribe"}
  step %{I should see "You are now following #{name}. If you'd like to stop receiving email updates, you can unsubscribe from your Subscriptions page."}
  step %{I go to the subscriptions page for "#{user}"}
  step %{I should see an "Unsubscribe from #{name}" button}
end

Then "the feed should have exactly {int} author(s)" do |int|
  expect(page).to have_selector(:xpath, "//author").exactly(int)
end

# rubocop:disable Cucumber/RegexStepName
Then /^the (\d+)(?:st|nd|rd|th) feed author should contain "([^"]*)"$/ do |n, text|
  within(:xpath, "//author[#{n}]") do
    expect(page).to have_content(text)
  end
end

Then /^the (\d+)(?:st|nd|rd|th) feed author should not have a link$/ do |n|
  expect(page).not_to have_selector(:xpath, "//author[#{n}]/uri")
end
# rubocop:enable Cucumber/RegexStepName
