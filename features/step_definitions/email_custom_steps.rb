Given "the email queue is clear" do
  reset_mailer
end

Given "a locale with translated emails" do
  language = Language.find_or_create_by(short: "new", name: "New")
  Locale.create(iso: "new", name: "New", language: language, email_enabled: true)
  # These keys are used in every email
  I18n.backend.store_translations(:new, { mailer: { general: { footer: { general: { about: { html: "Translated footer", text: "Translated footer" } } } } } })
end

Given "the user {string} enables translated emails" do |user|
  user = User.find_by(login: user)
  $rollout.activate_user(:set_locale_preference, user)
  user.preference.update!(locale: Locale.find_by(iso: "new"))
end

Then "the email to {string} should be translated" do |user|
  step(%{the email to "#{user}" should contain "Translated footer"})
  step(%{the email to "#{user}" should not contain "fan-run and fan-supported archive"}) # untranslated English text
  step(%{the email to "#{user}" should not contain "translation missing"}) # missing translations in the target language fall back to English
end

Then "{string} should be emailed" do |user|
  @user = User.find_by(login: user)
  expect(emails("to: \"#{email_for(@user.email)}\"").size).to be_positive
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

Then "{string} should receive {int} email(s)" do |user, count|
  @user = User.find_by(login: user)
  expect(emails("to: \"#{email_for(@user.email)}\"").size).to eq(count.to_i)
end
