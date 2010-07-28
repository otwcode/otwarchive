Given /^basic skins$/ do
  Skin.create_default
  Skin.import_plain_text
end
