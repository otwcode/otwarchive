Given /^basic skins$/ do
  Skin.create_default
  Skin.create_light
  Skin.import_plain_text
end
