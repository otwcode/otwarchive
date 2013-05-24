# GIVEN

Given /^I have the default comment notifications setup$/ do
end

Given /^I have the receive all comment notifications setup$/ do
  step %{I set my preferences to receive copies of my own comments}
end

Given /^I have the receive no comment notifications setup$/ do
  user = User.current_user
  user.preference.comment_emails_off = true
  user.preference.kudos_emails_off = true
  user.preference.admin_emails_off = true
  user.preference.save
end

# THEN

Then /^I should see Posted today$/ do
  today = Date.today.to_s(:date_for_comment_test)
  step "I should see \"Posted #{today}\""
end

Then /^I should see Posted nowish$/ do
  nowish = Time.zone.now.strftime('%a %d %b %Y %I:%M%p')
  step "I should see \"Posted #{nowish}\""
end

Then /^I should see Last Edited nowish$/ do
  nowish = Time.zone.now.strftime('%a %d %b %Y %I:%M%p')
  step "I should see \"Last Edited #{nowish}\""
end

Then /^I should see the comment form$/ do
  step %{I should see "New comment on"}
end

# WHEN

When /^I set up the comment "([^"]*)" on the work "([^"]*)"$/ do |comment_text, work|
  work = Work.find_by_title!(work)
  visit work_url(work)
  fill_in("comment[content]", :with => comment_text)
end

When /^I post the comment "([^"]*)" on the work "([^"]*)"$/ do |comment_text, work|
  step "I set up the comment \"#{comment_text}\" on the work \"#{work}\""
  click_button("Comment")
end

When /^I post the comment "([^"]*)" on the work "([^"]*)" as a guest$/ do |comment_text, work|
  step "I am logged out"
  step "I set up the comment \"#{comment_text}\" on the work \"#{work}\""
  fill_in("Name", :with => "guest")
  fill_in("Email", :with => "guest@foo.com")
  click_button "Comment"
end

When /^I edit a comment$/ do
  step %{I follow "Edit"}
  fill_in("comment[content]", :with => "Edited comment")
  click_button "Update"
end

# this step assumes we are on a page with a comment form
When /^I post a comment "([^"]*)"$/ do |comment_text|
  fill_in("comment[content]", :with => comment_text)
  click_button("Comment")
end

# this step assumes that the reply-to-comment form can be opened
When /^I reply to a comment with "([^"]*)"$/ do |comment_text|
  step %{I follow "Reply"}
  step %{I should see the reply to comment form}
  with_scope(".odd") do
    fill_in("comment[content]", :with => comment_text)
    click_button("Comment")
  end
end

When /^I visit the new comment page for the work "([^"]+)"$/ do |work|
  work = Work.find_by_title!(work)
  visit new_work_comment_path(work, :only_path => false)
end

When /^I comment on an admin post$/ do
  step "I go to the admin-posts page"
    step %{I follow "Comment"}
    step %{I fill in "comment[content]" with "Excellent, my dear!"}
    step %{I press "Comment"}
end

When /^I compose an invalid comment(?: within "([^"]*)")?$/ do |selector|
  with_scope(selector) do
    fill_in("Comment", :with => %/Sed mollis sapien ac massa pulvinar facilisis. Nulla rhoncus neque nisi. Integer sit amet nulla vel orci hendrerit aliquam. Proin vehicula bibendum vulputate. Nullam porttitor, arcu eu mollis accumsan, turpis justo ornare tellus, ac congue lectus purus ut risus. Phasellus feugiat, orci id tempor elementum, sapien nulla dignissim sapien, dictum eleifend nisl erat vitae urna. Cras imperdiet bibendum porttitor. Suspendisse vitae tellus nibh, vel facilisis magna. Quisque nec massa augue. Pellentesque in ipsum lacus. Aenean mauris leo, viverra sit amet fringilla sit amet, volutpat eu risus. Etiam scelerisque, nibh a condimentum eleifend, augue ipsum blandit tortor, lacinia pharetra ante felis eget lorem. Proin tristique dictum placerat. Aenean commodo imperdiet massa et auctor. Phasellus eleifend posuere varius.
Sed bibendum nisl vel ligula rhoncus at laoreet lorem lacinia. Vivamus est est, euismod vel pretium in, aliquam ac turpis. Integer ac leo sem, vel egestas lacus. Duis id nibh magna, vel adipiscing erat. Aliquam arcu velit, laoreet eget laoreet eget, semper id augue. Nullam volutpat pretium turpis vitae molestie. Ut id nisi eget nibh blandit blandit malesuada et sem. Fusce at accumsan erat. Sed sed adipiscing tortor. Proin vitae eros eget neque dignissim ullamcorper. Vestibulum eleifend nisl sed erat molestie suscipit. Fusce rutrum dignissim diam vel ultricies. Proin nec consequat velit. Aliquam eu nulla urna. Morbi ac orci nisl.
Vivamus vitae felis erat, a hendrerit nisi. Nullam et nunc sed est laoreet tempus non at nibh. Pellentesque tincidunt, diam eu vestibulum pretium, diam metus volutpat risus, ut mollis augue dolor quis ligula. Fusce in placerat leo. Nullam quis orci dui. Donec ultrices quam ut metus blandit cursus. Quisque lobortis elit sit amet libero mollis quis egestas ipsum faucibus. Curabitur sit amet sollicitudin metus. Vivamus sit amet justo eget felis dictum scelerisque in eu mauris. Vestibulum in diam ligula, et convallis ante. Praesent risus magna, adipiscing in vehicula eu, interdum eu arcu. Duis in nisl libero, nec posuere massa. Vestibulum pretium fermentum dui et dignissim. Mauris at diam sed purus faucibus tristique. Maecenas non orci et augue dignissim tempor. Sed vestibulum condimentum faucibus.
Morbi nec ullamcorper dolor. In luctus vulputate arcu et egestas. Nullam at pretium enim. Nulla congue tincidunt dignissim. Fusce malesuada odio nec turpis sagittis et accumsan tellus iaculis. Mauris eu libero non diam pretium feugiat quis in mauris. Vestibulum ut facilisis massa. Cras est metus, pulvinar eget ullamcorper in, eleifend id est. Ut ac bibendum elit. Vestibulum quis eros sem. Duis elementum congue lorem, nec semper justo adipiscing vitae. Nam eget velit est, nec varius leo. Quisque aliquet aliquet elit, eu elementum enim lacinia aliquam. Suspendisse laoreet convallis interdum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In quis velit massa. Nullam lectus risus, condimentum ac fringilla eu, pretium sed metus.
Nunc eget dolor ut nisi laoreet scelerisque. Vestibulum condimentum dignissim leo ut luctus. Aliquam sed sem velit. Nulla justo nulla, molestie cursus mollis eget, ullamcorper aliquet mi. Duis et sem elit, quis pretium diam. Nam consectetur ullamcorper velit, varius vulputate dui ultrices sodales. Sed aliquet laoreet tortor, vitae varius enim ornare vel. Nam ornare dapibus aliquam. Proin faucibus tellus eget nibh lacinia in dignissim odio ultricies. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nulla aliquet pulvinar turpis vitae malesuada. Mauris porttitor erat in urna bibendum luctus. Vestibulum nec mi eros, nec rutrum ligula. Nunc ac nisl eros, ut adipiscing diam. Integer feugiat justo a purus fermentum sollicitudin. Mauris lacinia venenatis commodo. Nam urna libero, viverra in rhoncus vel, ultricies vitae augue. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Morbi vitae lacus vitae magna volutpat pharetra rhoncus eget nisi. Proin vehicula, felis nec tempor eleifend, dolor ipsum volutpat dolor, et eleifend nibh libero ac turpis. Donec odio est, sodales nec consectetur vehicula, adipiscing sit amet magna. Suspendisse dapibus tincidunt velit sit amet mollis. Curabitur eget blandit li./)
  end
end

When /^I delete the comment$/ do
  step %{I follow "Delete" within ".odd"}
    step %{I follow "Yes, delete!"}
end

Then /^I should see the reply to comment form$/ do
  step %{I should see "Comment as" within ".odd"}
end
