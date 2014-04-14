When /^I view the "([^\"]*)" works index$/ do |tag|
  visit works_path(:tag_id => tag.to_param)
end

When /^"([^\"]*)" subscribes to (author|work|series) "([^\"]*)"$/ do |user, type, name|
  case type
  when "author"
    step %{I am logged in as "#{name}"}
    step %{I am logged in as "#{user}"}
    step %{I go to #{name}'s user page}
  when "work"
    step %{I am logged in as "wip_author"}
      step %{I post the work "#{name}"}
      step %{I am logged in as "#{user}"}
      step %{I go to wip_author's user page}
      step %{I follow "#{name}"}
  when "series"
    step %{I am logged in as "series_author"}
      step %{I add the work "Blah" to series "#{name}"}
      step %{I am logged in as "#{user}"}
      step %{I view the series "#{name}"}
  end
  step %{I press "Subscribe"}
  step %{I should see "You are now following #{name}"}
  step %{I go to my subscriptions page}
  step %{I should find "Unsubscribe from #{name}"}
end
