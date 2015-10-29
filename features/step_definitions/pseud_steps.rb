When /^I change the pseud "([^\"]*)" to "([^\"]*)"/ do |old_pseud, new_pseud|
  step %{I edit the pseud "#{old_pseud}"}
  fill_in("Name", with: new_pseud)
  click_button("Update")
end

When /^I edit the pseud "([^\"]*)"/ do |pseud| 
  p = Pseud.where(name: pseud, user_id: User.current_user.id).first
  visit edit_user_pseud_path(User.current_user, p)
end

When /^I add the pseud "([^\"]*)"/ do |pseud| 
  visit new_user_pseud_path(User.current_user)
  fill_in("Name", with: pseud)
  click_button("Create")
end

When(/^I delete the pseud "([^\"]*)"$/) do |pseud|
  visit user_pseuds_path(User.current_user)
  click_link("delete_#{pseud}")
end
