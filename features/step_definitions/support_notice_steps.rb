### GIVEN

Given "there are no support notices" do
  SupportNotice.delete_all
end

### WHEN

When /^an admin creates an?( active)?(?: "([^"]*)")? support notice$/ do |active, notice_type| # rubocop:disable Cucumber/RegexStepName
  step %{I am logged in as a "support" admin}
  visit(new_admin_support_notice_path)
  fill_in("support_notice_notice", with: "This is some support notice text")
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
  step %{I should see "Support Notice successfully created."} if active.present?
end

When "an admin deactivates the support notice" do
  step %{I am logged in as a "support" admin}
  step %{I am on the support notices page}
  step %{I follow "Edit"}
  uncheck("support_notice_active")
  click_button("Update Support Notice")
  step %{I should see "Support Notice successfully updated."}
end

When "an admin edits the active support notice" do
  step %{I am logged in as a "support" admin}
  step %{I am on the support notices page}
  step %{I follow "Edit"}
  fill_in("support_notice_notice", with: "This is some edited support notice text")
  click_button("Update Support Notice")
  step %{I should see "Support Notice successfully updated."}
end

When "an admin creates a newer active support notice" do
  step %{I am logged in as a "support" admin}
  visit(new_admin_support_notice_path)
  fill_in("support_notice_notice", with: "This is new support notice text")
  check("support_notice_active")
  click_button("Create Support Notice")
  step %{I should see "Support Notice successfully created."}
end

### THEN

Then /^I should see the(?: "([^"]*)")? support notice$/ do |notice_type| # rubocop:disable Cucumber/RegexStepName
  visit(feedbacks_path)
  case notice_type
  when "notice"
    page.should have_xpath("//div[@class='userstuff' and .//div[@class='notice']]")
  when "caution"
    page.should have_xpath("//div[@class='userstuff' and .//div[@class='notice caution']]")
  when "error"
    page.should have_xpath("//div[@class='userstuff' and .//div[@class='notice error']]")
  else
    page.should have_xpath("//div[@class='userstuff' and .//div[contains(@class, 'notice')]]")
  end
  step %{I should see "This is some support notice text"}
end

Then "I should see the edited active support notice" do
  visit(feedbacks_path)
  step %{I should see "This is some edited support notice text"}
end

Then "I should not see a support notice" do
  visit(feedbacks_path)
  page.should_not have_xpath("//div[@class='userstuff' and .//div[contains(@class, 'notice')]]")
end

Then "I should see the new support notice" do
  visit(feedbacks_path)
  step %{I should see "This is new support notice text"}
  step %{I should not see "This is some support notice text"}
end
