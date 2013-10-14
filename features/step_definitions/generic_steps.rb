When /^(?:|I )unselect "([^"]+)" from "([^"]+)"$/ do |item, selector|
  unselect(item, :from => selector)
end

Then /^debug$/ do
  breakpoint
  0
end

Then /^show me the response$/ do
  puts page.body
end

Then /^show me the html$/ do
  puts page.body
end

Then /^show me the main content$/ do
  puts "\n" + find("#main").native.inner_html
end

Then /^show me the errors$/ do 
  puts "\n" + find("div.error").native.inner_html
end

Then /^show me the sidebar$/ do
  puts "\n" + find("#dashboard").native.inner_html
end

Then /^I should see errors/ do
  assert find("div.error")
end

Then /^show me the form$/ do
  step %{show me the 1st form}
end

Then /^show me the (\d+)(?:st|nd|rd|th) form$/ do |index|
  puts "\n" + page.all("#main form")[(index.to_i-1)].native.inner_html
end


Given /^I wait (\d+) seconds?$/ do |number|
  Kernel::sleep number.to_i
end

When 'the system processes jobs' do
  #resque runs inline during testing. see resque.rb in initializers/gem-plugin_config
  #Delayed::Worker.new.work_off
end

When 'I reload the page' do
  visit current_url
end

Then /^I should see Posted now$/ do
	now = Time.zone.now.to_s
  step "I should see \"Posted #{now}\""
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

Then /^I should see a create confirmation message$/ do
  page.should have_content('was successfully created')
end

Then /^I should see an update confirmation message$/ do
  page.should have_content('was successfully updated')
end

Then /^I should see a save error message$/ do
  step %{I should see "We couldn't save"}
end

Then /^I should see a success message$/ do
  step %{I should see "success"}
end

Then /^I should find "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    page.all(text)
  end
end

Then /^I should find '([^']*)'(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    page.all(text)
  end
end

Then /^I should not find "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    page.all(text)
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
  page.has_select?(field, :selected => value).should == true
  #find_field(field).xpath(".//option[@selected = 'selected']").inner_html.should =~ /#{value}/
end

Then /^I should see "([^"]*)" in the "([^"]*)" input/ do |content, labeltext|
  find_field("#{labeltext}").value.should == content
end

When /^"([^\"]*)" is fixed$/ do |what|
  puts "\nDEFERRED (#{what})"
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be disabled$/ do |label, selector|
  with_scope(selector) do
    field_disabled = find_field(label, :disabled => true)
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


When /^I check the (\d+)(?:st|nd|rd|th) checkbox with the value "([^"]*)"$/ do |index, value|
  check(page.all("input[type='checkbox']").select {|el| el['value'] == value}[(index.to_i-1)]['id'])
end

When /^I check the (\d+)(st|nd|rd|th) checkbox with value "([^"]*)"$/ do |index, suffix, value|
  step %{I check the #{index}#{suffix} checkbox with the value "#{value}"}
end

When /^I uncheck the (\d+)(?:st|nd|rd|th) checkbox with the value "([^"]*)"$/ do |index, value|
  uncheck(page.all("input[type='checkbox']").select {|el| el['value'] == value}[(index.to_i-1)]['id'])
end

When /^I check the (\d+)(?:st|nd|rd|th) checkbox with id matching "([^"]*)"$/ do |index, id_string|
  check(page.all("input[type='checkbox']").select {|el| el['id'] && el['id'].match(/#{id_string}/)}[(index.to_i-1)]['id'])
end

When /^I fill in the (\d+)(?:st|nd|rd|th) field with id matching "([^"]*)" with "([^"]*)"$/ do |index, id_string, value|
  fill_in(page.all("input[type='text']").select {|el| el['id'] && el['id'].match(/#{id_string}/)}[(index.to_i-1)]['id'], :with => value)
end


# These submit steps will only find submit tags inside a <p class="submit">
# That wrapping paragraph tag will be generated automatically if you use
# the submit_button or submit_fieldset helpers in application_helper.rb
# The text on the button will not matter and can be changed without breaking tests. 
#
# NOTE: 
# If you have multiple forms on a page you will need to specify which one you want to submit with, eg,
# "I submit with the 2nd button", but in those cases you probably want to make sure that
# the different forms have different button text anyway, and submit them using
# When I press "Button Text"
When /^I submit with the (\d+)(?:st|nd|rd|th) button$/ do |index|
  page.all("p.submit input[type='submit']")[(index.to_i-1)].click
end

# This will submit the first submit button in a page by default
When /^I submit$/ do
  step %{I submit with the 1st button}
end

# we want greedy matching for this one so we can handle tags that have attributes in them
Then /^I should see the text with tags "(.*)"$/ do |text|
  page.body.should =~ /#{text}/m
end

Then /^I should see the text with tags '(.*)'$/ do |text|
  page.body.should =~ /#{text}/m
end

Then /^I should not see the text with tags '(.*)'$/ do |text|
  page.body.should_not =~ /#{text}/m
end

Then /^I should see the page title "(.*)"$/ do |text|
  within('head title') do
    page.should have_content(text)
  end
end

Given /^I have no prompts$/ do
  Prompt.delete_all
end

Then /^I should find a checkbox "([^\"]*)"$/ do |name|
  field = find_field(name)
  field['checked'].respond_to? :should
end

Then /^I should see a link "([^\"]*)"$/ do |name|
  text = name + "</a>"
  page.body.should =~ /#{text}/m
end

Then /^I should not see a link "([^\"]*)"$/ do |name|
  text = name + "</a>"
  page.body.should_not =~ /#{text}/m
end
