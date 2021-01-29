# GIVEN

Given /^I have the default comment notifications setup$/ do
end

Given /^I have the receive all comment notifications setup$/ do
  step %{I set my preferences to turn on copies of my own comments}
end

Given /^I have the receive no comment notifications setup$/ do
  user = User.current_user
  user.preference.comment_emails_off = true
  user.preference.kudos_emails_off = true
  user.preference.save
end

# THEN

Then /^the comment's posted date should be nowish$/ do
  nowish = Time.zone.now.strftime('%a %d %b %Y %I:%M%p')
  step %{I should see "#{nowish}" within ".posted.datetime"}
end

Then /^I should see Last Edited nowish$/ do
  nowish = Time.zone.now.strftime('%a %d %b %Y %I:%M%p')
  step "I should see \"Last Edited #{nowish}\""
end

Then /^I should see the comment form$/ do
  step %{I should see "New comment on"}
end

Then /^I should see the reply to comment form$/ do
  step %{I should see "Comment as" within ".odd"}
end

Then /^I should see Last Edited in the right timezone$/ do
  zone = Time.current.in_time_zone(Time.zone).zone
  step %{I should see "#{zone}" within ".comment .posted"}
  step %{I should see "Last Edited"}
end

# WHEN

When /^I set up the comment "([^"]*)" on the work "([^"]*)"$/ do |comment_text, work|
  work = Work.find_by(title: work)
  visit work_path(work)
  fill_in("comment[comment_content]", with: comment_text)
end

When /^I attempt to comment on "([^"]*)" with a pseud that is not mine$/ do |work|
  step %{I am logged in as "commenter"}
  step %{I set up the comment "This is a test" on the work "#{work}"}
  work_id = Work.find_by(title: work).id
  pseud_id = User.first.pseuds.first.id
  find("#comment_pseud_id_for_#{work_id}", visible: false).set(pseud_id)
  click_button "Comment"
end

When /^I attempt to update a comment on "([^"]*)" with a pseud that is not mine$/ do |work|
  step %{I am logged in as "commenter"}
  step %{I post the comment "blah blah blah" on the work "#{work}"}
  step %{I follow "Edit"}
  pseud_id = User.first.pseuds.first.id
  find(:xpath, "//input[@name='comment[pseud_id]']", visible: false).set(pseud_id)
  click_button "Update"
end

When /^I post the comment "([^"]*)" on the work "([^"]*)"$/ do |comment_text, work|
  step "I set up the comment \"#{comment_text}\" on the work \"#{work}\""
  click_button("Comment")
end

When /^I post the comment "([^"]*)" on the work "([^"]*)" as a guest(?: with email "([^"]*)")?$/ do |comment_text, work, email|
  step "I start a new session"
  step "I set up the comment \"#{comment_text}\" on the work \"#{work}\""
  fill_in("Guest name", with: "guest")
  fill_in("Guest email", with: (email || "guest@foo.com"))
  click_button "Comment"
end

When /^I edit a comment$/ do
  step %{I follow "Edit"}
  fill_in("comment[comment_content]", with: "Edited comment")
  click_button "Update"
end

# this step assumes we are on a page with a comment form
When /^I post a comment "([^"]*)"$/ do |comment_text|
  fill_in("comment[comment_content]", with: comment_text)
  click_button("Comment")
end

# this step assumes that the reply-to-comment form can be opened
When /^I reply to a comment with "([^"]*)"$/ do |comment_text|
  step %{I follow "Reply"}
  step %{I should see the reply to comment form}
  with_scope(".odd") do
    fill_in("comment[comment_content]", with: comment_text)
    click_button("Comment")
  end
end

When /^I visit the new comment page for the work "([^"]+)"$/ do |work|
  work = Work.find_by(title: work)
  visit new_work_comment_path(work, only_path: false)
end

When /^I comment on an admin post$/ do
  step "I go to the admin-posts page"
  step %{I follow "Default Admin Post"}
  step %{I fill in "comment[comment_content]" with "Excellent, my dear!"}
  step %{I press "Comment"}
end

When /^I post a spam comment$/ do
  fill_in("comment[name]", with: "spammer")
  fill_in("comment[email]", with: "spammer@example.org")
  fill_in("comment[comment_content]", with: "Buy my product! http://spam.org")
  click_button("Comment")
  step %{I should see "Comment created!"}
end

When /^I post a guest comment$/ do
  fill_in("comment[name]", with: "guest")
  fill_in("comment[email]", with: "guest@example.org")
  fill_in("comment[comment_content]", with: "This was really lovely!")
  click_button("Comment")
  step %{I should see "Comment created!"}
end

When /^all comments by "([^"]*)" are marked as spam$/ do |name|
  Comment.where(name: name).find_each(&:mark_as_spam!)
end

When /^I compose an invalid comment(?: within "([^"]*)")?$/ do |selector|
  with_scope(selector) do
    fill_in("Comment", with: %/Sed mollis sapien ac massa pulvinar facilisis. Nulla rhoncus neque nisi. Integer sit amet nulla vel orci hendrerit aliquam. Proin vehicula bibendum vulputate. Nullam porttitor, arcu eu mollis accumsan, turpis justo ornare tellus, ac congue lectus purus ut risus. Phasellus feugiat, orci id tempor elementum, sapien nulla dignissim sapien, dictum eleifend nisl erat vitae urna. Cras imperdiet bibendum porttitor. Suspendisse vitae tellus nibh, vel facilisis magna. Quisque nec massa augue. Pellentesque in ipsum lacus. Aenean mauris leo, viverra sit amet fringilla sit amet, volutpat eu risus. Etiam scelerisque, nibh a condimentum eleifend, augue ipsum blandit tortor, lacinia pharetra ante felis eget lorem. Proin tristique dictum placerat. Aenean commodo imperdiet massa et auctor. Phasellus eleifend posuere varius.
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

When /^I delete the reply comment$/ do
  step %{I follow "Delete" within ".even"}
  step %{I follow "Yes, delete!"}
end

When /^I view the latest comment$/ do
  visit comment_path(Comment.last)
end

Given(/^the moderated work "([^\"]*?)" by "([^\"]*?)"$/) do |work, user|
  step %{I am logged in as "#{user}"}
  step %{I set up the draft "#{work}"}
  check("work_moderated_commenting_enabled")
  step %{I post the work without preview}
end

Then /^comment moderation should be enabled on "([^\"]*?)"/ do |work|
  w = Work.find_by(title: work)
  assert w.moderated_commenting_enabled?
end

Then /^comment moderation should not be enabled on "([^\"]*?)"/ do |work|
  w = Work.find_by(title: work)
  assert !w.moderated_commenting_enabled?
end

Then /^the comment on "([^\"]*?)" should be marked as unreviewed/ do |work|
  w = Work.find_by(title: work)
  assert w.comments.first.unreviewed?
end

Then /^the comment on "([^\"]*?)" should not be marked as unreviewed/ do |work|
  w = Work.find_by(title: work)
  assert !w.comments.first.unreviewed?
end

When /^I view the unreviewed comments page for "([^\"]*?)"/ do |work|
  w = Work.find_by(title: work)
  visit unreviewed_work_comments_path(w)
end

When /^I visit the thread for the comment on "([^\"]*?)"/ do |work|
  w = Work.find_by(title: work)
  visit comment_path(w.comments.first)
end

Then /^there should be (\d+) comments on "([^\"]*?)"/ do |num, work|
  w = Work.find_by(title: work)
  assert w.find_all_comments.count == num.to_i
end

Given /^the moderated work "([^\"]*)" by "([^\"]*)" with the approved comment "([^\"]*)" by "([^\"]*)"/ do |work, author, comment, commenter|
  step %{the moderated work "#{work}" by "#{author}"}
  step %{I am logged in as "#{commenter}"}
  step %{I post the comment "#{comment}" on the work "#{work}"}
  step %{I am logged in as "#{author}"}
  step %{I view the unreviewed comments page for "#{work}"}
  step %{I press "Approve"}
end

When /^I reload the comments on "([^\"]*?)"/ do |work|
  w = Work.find_by(title: work)
  w.find_all_comments.each { |c| c.reload }
end

When /^I post a deeply nested comment thread on "([^\"]*?)"$/ do |work|
  work = Work.find_by(title: work)
  chapter = work.chapters[0]
  user = User.current_user

  commentable = chapter

  count = ArchiveConfig.COMMENT_THREAD_MAX_DEPTH + 1

  count.times do |i|
    commentable = Comment.create(
      commentable: commentable,
      parent: chapter,
      comment_content: "This is a comment at depth #{i}.",
      pseud: user.default_pseud
    )
  end

  # As long as there's only one child comment, it'll keep displaying the child.
  # So we need two comments at the final depth:
  2.times do |i|
    ordinal = i.zero? ? "first" : "second"
    Comment.create(
      commentable: commentable,
      parent: chapter,
      comment_content: "This is the #{ordinal} hidden comment.",
      pseud: user.default_pseud
    )
  end
end

Then /^I (should|should not) see the deeply nested comments$/ do |should_or_should_not|
  step %{I #{should_or_should_not} see "This is the first hidden comment."}
  step %{I #{should_or_should_not} see "This is the second hidden comment."}
end

When /^I delete all visible comments on "([^\"]*?)"$/ do |work|
  work = Work.find_by(title: work)

  loop do
    visit work_url(work, show_comments: true)
    break unless page.has_content? "Delete"
    click_link("Delete")
    click_link("Yes, delete!") # TODO: Fix along with comment deletion.
  end
end
