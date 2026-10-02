require "spec_helper"

describe "rake db:populate_locale_languages_table" do
  let!(:language) do
    create(:language, name: "Suomi", short: "fi", sortable_name: "su")
  end

  context "when no locale language with the language's id exists" do
    it "creates a locale language with the language's attributes" do
      expect do
        subject.invoke
      end.to output(/1 created, \d+ updated, 0 failed/).to_stdout

      locale_language = LocaleLanguage.find(language.id)
      expect(locale_language.name).to eq("Suomi")
      expect(locale_language.short).to eq("fi")
      expect(locale_language.sortable_name).to eq("su")
    end
  end

  context "when a locale language with the language's id exists" do
    before do
      LocaleLanguage.create!(id: language.id, name: "Outdated", short: "xx")
    end

    it "updates the locale language with the language's attributes" do
      expect do
        subject.invoke
      end.to output(/0 created, \d+ updated, 0 failed/).to_stdout

      locale_language = LocaleLanguage.find(language.id)
      expect(locale_language.name).to eq("Suomi")
      expect(locale_language.short).to eq("fi")
    end
  end

  context "when a locale language cannot be saved" do
    before do
      # Use an id that can't match language.id, so the task builds a new row
      # that collides with this one's unique name.
      LocaleLanguage.create!(id: language.id + 1_000, name: "Suomi", short: "zz")
    end

    it "reports the failure and continues" do
      expect do
        subject.invoke
      end.to output(/Failed to sync locale language for language #{language.id}.*1 failed/m).to_stdout
    end
  end
end
