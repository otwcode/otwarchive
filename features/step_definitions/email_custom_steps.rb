Given "the email queue is clear" do
  reset_mailer
end

Given "a locale with translated emails" do
  FactoryBot.create(:locale, iso: "new")
  # The footer keys are used in most emails
  I18n.backend.store_translations(:new, { mailer: { general: { footer: { general: { about: { html: "Translated footer", text: "Translated footer" } } } } } })
  I18n.backend.store_translations(:new, { kudo_mailer: { batch_kudo_notification: { subject: "Translated subject" } } })
  I18n.backend.store_translations(:new, { users: { mailer: { reset_password_instructions: { subject: "Translated subject" } } } })
end

Given "the user {string} enables translated emails" do |user|
  user = User.find_by(login: user)
  $rollout.activate_user(:set_locale_preference, user)
  user.preference.update!(locale: Locale.find_by(iso: "new"))
end

Given "the locale preference feature flag is disabled for user {string}" do |user|
  user = User.find_by(login: user)
  $rollout.deactivate_user(:set_locale_preference, user)
end

Then "the email to {string} should be translated" do |user|
  step(%{the email to "#{user}" should contain "Translated footer"})
  step(%{the email to "#{user}" should not contain "fan-run and fan-supported archive"}) # untranslated English text
  step(%{the email to "#{user}" should not contain "translation missing"}) # missing translations in the target language fall back to English
end

Then "the email to email address {string} should be translated" do |email_address|
  step(%{the email to email address "#{email_address}" should contain "Translated footer"})
  step(%{the email to email address "#{email_address}" should not contain "fan-run and fan-supported archive"}) # untranslated English text
  step(%{the email to email address "#{email_address}" should not contain "translation missing"}) # missing translations in the target language fall back to English
end

Then "the last email to {string} should be translated" do |user|
  step(%{the last email to "#{user}" should contain "Translated footer"})
  step(%{the last email to "#{user}" should not contain "fan-run and fan-supported archive"}) # untranslated English text
  step(%{the last email to "#{user}" should not contain "translation missing"}) # missing translations in the target language fall back to English
end

Then "the email to {string} should be non-translated" do |user|
  step(%{the email to "#{user}" should not contain "Translated footer"})
  step(%{the email to "#{user}" should contain "fan-run and fan-supported archive"})
  step(%{the email to "#{user}" should not contain "translation missing"})
end

Then "{string} should be emailed" do |user|
  @user = User.find_by(login: user)
  expect(emails("to: \"#{email_for(@user.email)}\"")).not_to be_empty
end

Then "the email address {string} should be emailed" do |email_address|
  expect(emails("to: \"#{email_for(email_address)}\"")).not_to be_empty
end

Then "{string} should not be emailed" do |user|
  @user = User.find_by(login: user)
  expect(emails("to: \"#{email_for(@user.email)}\"")).to be_empty
end

Then "the email to {string} should contain {string}" do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").first
  if email.multipart?
    expect(email.text_part.body).to match(text)
    expect(email.html_part.body).to match(text)
  else
    expect(email.body).to match(text)
  end
end

Then "the email to email address {string} should contain {string}" do |email_address, text|
  email = emails("to: \"#{email_for(email_address)}\"").first
  if email.multipart?
    expect(email.text_part.body).to match(text)
    expect(email.html_part.body).to match(text)
  else
    expect(email.body).to match(text)
  end
end

Then "the last email to {string} should contain {string}" do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").last
  if email.multipart?
    expect(email.text_part.body).to match(text)
    expect(email.html_part.body).to match(text)
  else
    expect(email.body).to match(text)
  end
end

Then "the email to {string} should not contain {string}" do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").first
  if email.multipart?
    expect(email.text_part.body).not_to match(text)
    expect(email.html_part.body).not_to match(text)
  else
    expect(email.body).not_to match(text)
  end
end

Then "the email to email address {string} should not contain {string}" do |email_address, text|
  email = emails("to: \"#{email_for(email_address)}\"").first
  if email.multipart?
    expect(email.text_part.body).not_to match(text)
    expect(email.html_part.body).not_to match(text)
  else
    expect(email.body).not_to match(text)
  end
end

Then "the last email to {string} should not contain {string}" do |user, text|
  @user = User.find_by(login: user)
  email = emails("to: \"#{email_for(@user.email)}\"").last
  if email.multipart?
    expect(email.text_part.body).not_to match(text)
    expect(email.html_part.body).not_to match(text)
  else
    expect(email.body).not_to match(text)
  end
end

Then "{string} should receive {int} email(s)" do |user, count|
  @user = User.find_by(login: user)
  expect(emails("to: \"#{email_for(@user.email)}\"").size).to eq(count.to_i)
end
