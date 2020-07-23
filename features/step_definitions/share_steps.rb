Then /^the share modal should contain a Twitter share button$/ do
  with_scope('#share') do
    iframe = find('li.twitter #twitter-widget-0')
    within_frame(iframe) do
      page.should have_content("Tweet")
    end
  end
end
