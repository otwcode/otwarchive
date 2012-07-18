When /^I view the "([^\"]*)" works index$/ do |tag|
  When %{I view the tag "#{tag}"}
end

When /^"([^\"]*)" subscribes to (author|work|series) "([^\"]*)"$/ do |user, type, name|
  case type
  when "author"
    When %{I am logged in as "#{name}"}
    And %{I am logged in as "#{user}"}
    And %{I go to #{name}'s user page}
  when "work"
    When %{I am logged in as "wip_author"}
      And %{I post the work "#{name}"}
      And %{I am logged in as "#{user}"}
      And %{I go to wip_author's user page}
      And %{I follow "#{name}"}
  when "series"
    When %{I am logged in as "series_author"}
      And %{I add the work "Blah" to series "#{name}"}
      And %{I am logged in as "#{user}"}
      And %{I view the series "#{name}"}
  end
  When %{I press "Subscribe"}
  Then %{I should see "You are now following #{name}"}
  When %{I go to my subscriptions page}
  Then %{I should find "Unsubscribe from #{name}"}
end
