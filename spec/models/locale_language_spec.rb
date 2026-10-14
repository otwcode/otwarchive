require "spec_helper"

describe LocaleLanguage do
  describe ".default_order" do
    it "returns locale languages sorted alphabetically by sortable_name if present, short name if not" do
      german = create(:locale_language, name: "Deutsch", short: "de", sortable_name: "")
      finnish = create(:locale_language, name: "Suomi", short: "fi", sortable_name: "su")
      indonesian = create(:locale_language, name: "Bahasa Indonesia", short: "id", sortable_name: "ba")
      locale_languages = LocaleLanguage.where(id: [german.id, finnish.id, indonesian.id])
      expect(locale_languages.default_order).to eq([indonesian, german, finnish])
    end
  end

  describe ".default" do
    it "returns the default locale language" do
      default = LocaleLanguage.default
      expect(default.short).to eq(ArchiveConfig.DEFAULT_LANGUAGE_SHORT)
      expect(default.name).to eq(ArchiveConfig.DEFAULT_LANGUAGE_NAME)
    end

    it "creates the default locale language if it does not exist" do
      Locale.where(language_id: LocaleLanguage.default.id).delete_all
      LocaleLanguage.where(short: ArchiveConfig.DEFAULT_LANGUAGE_SHORT).destroy_all
      expect { LocaleLanguage.default }
        .to change(LocaleLanguage, :count).by(1)
    end
  end

  describe "#to_param" do
    it "returns the short name" do
      locale_language = create(:locale_language, short: "fi")
      expect(locale_language.to_param).to eq("fi")
    end
  end

  describe "validations" do
    context "for :short" do
      it "is invalid if blank" do
        locale_language = LocaleLanguage.new(name: "Korean", short: "")
        expect(locale_language).not_to be_valid
        expect(locale_language.errors[:short]).to include("can't be blank")
      end

      it "is valid with a value 4 characters or fewer" do
        locale_language = LocaleLanguage.new(name: "Korean", short: "ko")
        expect(locale_language).to be_valid
      end

      it "is invalid if longer than 4 characters" do
        locale_language = LocaleLanguage.new(name: "Korean", short: "korean")
        expect(locale_language).not_to be_valid
        expect(locale_language.errors[:short]).to include("is too long (maximum is 4 characters)")
      end

      it "is invalid if not unique" do
        create(:locale_language, short: "fi")
        duplicate = LocaleLanguage.new(name: "Other", short: "fi")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:short]).to include("has already been taken")
      end
    end

    context "for :name" do
      it "is invalid if blank" do
        locale_language = LocaleLanguage.new(name: "", short: "ko")
        expect(locale_language).not_to be_valid
        expect(locale_language.errors[:name]).to include("can't be blank")
      end

      it "is valid with a unique value" do
        locale_language = LocaleLanguage.new(name: "Unique Name", short: "uniq")
        expect(locale_language).to be_valid
      end

      it "is invalid if not unique" do
        create(:locale_language, name: "Suomi", short: "fi")
        duplicate = LocaleLanguage.new(name: "Suomi", short: "su")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end
    end
  end

  describe "associations" do
    it "prevents deletion when locales exist" do
      locale_language = create(:locale_language)
      create(:locale, locale_language: locale_language)
      expect { locale_language.destroy! }
        .to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
