require "spec_helper"

describe Language do
  describe ".default_order" do
    it "returns languages sorted alphabetically by sortable_name if present, short name if not" do
      german = Language.create(name: "Deutsch", short: "de", sortable_name: "")
      finnish = Language.create(name: "Suomi", short: "fi", sortable_name: "su")
      indonesian = Language.create(name: "Bahasa Indonesia", short: "id", sortable_name: "ba")
      languages = Language.where(id: [german.id, finnish.id, indonesian.id])
      expect(languages.default_order).to eq([indonesian, german, finnish])
    end
  end

  describe "validations" do
    context "for :short" do
      it "is valid with a value 4 characters or fewer" do
        korean = Language.new(name: "Korean", short: "ko")

        expect(korean).to be_valid
      end

      it "is invalid if longer than 4 characters" do
        korean = Language.new(name: "Korean", short: "korean")

        expect(korean).not_to be_valid
        expect(korean.errors[:short]).to include("is too long (maximum is 4 characters)")
      end
    end

    context "for :name" do
      it "is valid with a unique value" do
        unique_language = Language.new(name: "Unique Language Name", short: "uniq")

        expect(unique_language).to be_valid
      end

      it "is invalid if not unique" do
        duplicate_language = Language.new(name: "English", short: "eng")

        expect(duplicate_language).not_to be_valid
        expect(duplicate_language.errors[:name]).to include("has already been taken")
      end
    end
  end
end
