Given /^I wait (\d+) seconds?$/ do |number|
  Kernel::sleep number.to_i
end

When 'the system processes jobs' do
  Delayed::Job.work_off
end

When 'I reload the page' do
  visit current_url
end

Then /^I should see Posted now$/ do
	now = Time.zone.now.to_s
  Given "I should see \"Posted #{now}\""
end

When /^I fill in "([^\"]*)" with$/ do |field, value|
  fill_in(field, :with => value)
end

When /^I fill in "([^\"]*)" with `([^\`]*)`$/ do |field, value|
  fill_in(field, :with => value)
end

When /^I fill in "([^\"]*)" with '([^\']*)'$/ do |field, value|
  fill_in(field, :with => value)
end

Then /^I should find "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    page.find(text)
  end
end

Then /^I should find '([^']*)'(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    page.find(text)
  end
end

Then /^I should not find "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    begin
      wait_until do
        page.find(text)
      end
    rescue Capybara::TimeoutError
    end
  end
end

Then /^I should see the "(alt|title)" text "([^\"]*)"(?: within "([^"]*)")?$/ do |texttype, text, selector|
  with_scope(selector) do
    (texttype == "alt") ? (page.should have_xpath("//img[@alt='#{text}']")) : (page.should have_xpath("//img[@title='#{text}']"))
  end
end

Then /^I should not see the "(alt|title)" text "([^\"]*)"(?: within "([^"]*)")?$/ do |texttype, text, selector|
  with_scope(selector) do
    (texttype == "alt") ? (page.should have_no_xpath("//img[@alt='#{text}']")) : (page.should have_no_xpath("//img[@title='#{text}']"))
  end
end

Then /^"([^"]*)" should be selected within "([^"]*)"$/ do |value, field|
  find_field(field).node.xpath(".//option[@selected = 'selected']").inner_html.should =~ /#{value}/
end

When /^issue "([^\"]*)" is fixed$/ do |issue_no|
  print "DEFERRED (Issue #{issue_no})"
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be disabled$/ do |label, selector|
  with_scope(selector) do
    field_disabled = find_field(label)['disabled']
    if field_disabled.respond_to? :should
      field_disabled.should be_true
    else
      assert field_disabled
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should not be disabled$/ do |label, selector|
  with_scope(selector) do
    field_disabled = find_field(label)['disabled']
    if field_disabled.respond_to? :should
      field_disabled.should be_false
    else
      assert !field_disabled
    end
  end
end

Then /^I should find "([^"]*)" selected within "([^"]*)"$/ do |text, selector|
    if page.respond_to? :should
      page.should have_content('<option selected="selected" value="' + text + '"')
    else
      assert page.has_content?('<option selected="selected" value="' + text + '"')
    end
end


