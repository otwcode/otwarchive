require "spec_helper"

describe Locale do
  it "has a default" do
    locale = Locale.default
    expect(locale.iso).to eq(ArchiveConfig.DEFAULT_LOCALE_ISO)
    expect(locale.name).to eq(ArchiveConfig.DEFAULT_LOCALE_NAME)
    expect(locale.locale_language).to eq(LocaleLanguage.default)
    expect(I18n.default_locale.to_s).to eq(ArchiveConfig.DEFAULT_LOCALE_ISO)
  end

  it "overrides to_param" do
    locale = Locale.default
    expect(locale.to_param).to eq(locale.iso)
  end
end
