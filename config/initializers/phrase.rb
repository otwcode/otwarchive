Phrase.configure do |config|
  # Enable or disable the PhraseApp context editor in general
  if ENV['AO3_PHRASE_APP'] == 'true' || ArchiveConfig.PHRASEAPP_ENABLE == 'true' then
    config.enabled = true 
  else 
    config.enabled = false 
  end

  # Fetch your project auth token after creating your first project
  # in the PhraseApp translation center.
  config.auth_token = ArchiveConfig.PHRASEAPP_TOKEN

  # Configure an array of key names that should not be handled
  # with PhraseApp. This is useful when a key causes problems
  # (Such as keys that are used by Rails internally)
  config.ignored_keys = []

  # PhraseApp uses decorators to generate a unique identification key
  # in context of your document. However, this might result in conflicts
  # with other libraries (e.g. client-side template engines) that use a similar syntax.
  # If you encounter this problem, you might want to change the phrase decorator.
  # More information: https://phraseapp.com/docs/installation/phrase-gem
  # config.prefix = "{{__"
  # config.suffix = "__}}"
end
