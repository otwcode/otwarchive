PhraseApp::InContextEditor.configure do |config|
  # Enable or disable the In-Context-Editor in general
  if ENV["AO3_PHRASE_APP"] == "true" || ArchiveConfig.PHRASEAPP_ENABLE == "true"
    config.enabled = true
  else
    config.enabled = false
  end

  # Configure with your project id and account id. You can find the
  # project id in your project settings and account id in your account
  # settings (https://app.phrase.com/)
  config.project_id = "a3667b8095533c2b3f8d3ac946bb642f"
  config.account_id = "c14670ca"

  # Configure an array of key names that should not be handled
  # by the In-Context-Editor.
  # Exclude keys from the faker, rack_dev and will_paginate gems.
  # Exclude keys that are already translated in the rails-i18n gem.
  config.ignored_keys = ["faker.*", "rack_dev.*", "will_paginate.*", "number.*", "date.*", "datetime.*", "support.array*", "time.*"]

  # Phrase uses decorators to generate a unique identification key
  # in context of your document. However, this might result in conflicts
  # with other libraries (e.g. client-side template engines) that use a similar syntax.
  # If you encounter this problem, you might want to change this decorator pattern.
  # More information: https://help.phrase.com/hc/en-us/articles/5784095916188-In-Context-Editor-Strings-
  # config.prefix = "{{__"
  # config.suffix = "__}}"
end
