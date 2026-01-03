### WHEN

When /^I create an?( active)?(?: "([^"]*)")? support notice$/ do |active, notice_type| # rubocop:disable Cucumber/RegexStepName
  visit(new_admin_support_notice_path)
  fill_in("support_notice_notice_content", with: "This is some support notice text")
  case notice_type
  when "caution"
    choose("support_notice_support_notice_type_caution")
  when "error"
    choose("support_notice_support_notice_type_error")
  else
    choose("support_notice_support_notice_type_notice")
  end
  check("support_notice_active") if active.present?
  click_button("Create Support Notice")
  step %{I should see "Support notice successfully created."}
end

When "I deactivate the support notice" do
  step %{I am on the support notices page}
  step %{I follow "Edit"}
  uncheck("support_notice_active")
  click_button("Update Support Notice")
  step %{I should see "Support notice successfully updated."}
end

When "I edit the active support notice" do
  step %{I am on the support notices page}
  step %{I follow "Edit"}
  fill_in("support_notice_notice_content", with: "This is some edited support notice text")
  click_button("Update Support Notice")
  step %{I should see "Support notice successfully updated."}
end

When "I create a newer active support notice" do
  step %{I am on the homepage}
  step %{I follow "Support Notices"}
  step %{I follow "New Support Notice"}

  fill_in("support_notice_notice_content", with: "This is new support notice text")
  check("support_notice_active")
  click_button("Create Support Notice")
  step %{I should see "Support notice successfully created."}
end

### THEN

Then /^I should see the(?: "([^"]*)")? support notice$/ do |notice_type| # rubocop:disable Cucumber/RegexStepName
  if notice_type
    expect(page).to have_selector(".support.banner.#{notice_type}")
  else
    expect(page).to have_selector(".support.banner")
  end
  step %{I should see "This is some support notice text"}
end

Then "I should see the edited active support notice" do
  step %{I should see "This is some edited support notice text"}
end

Then "I should not see a support notice" do
  expect(page).to_not have_selector(".support.banner")
  step %{I should not see "support notice text"}
end

Then "I should see the new support notice" do
  step %{I should see "This is new support notice text"}
  step %{I should not see "This is some support notice text"}
end
