require "spec_helper"

describe Language do
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of(:sortable_name) }
  it { is_expected.to validate_uniqueness_of(:short).case_insensitive }
  it { is_expected.to validate_length_of(:short).is_at_most(4) }

  describe ".default_order" do
    it "returns languages sorted alphabetically by sortable_name, case-insensitive" do
      german = Language.create(name: "Deutsch", short: "de", sortable_name: "Deutsch")
      finnish = Language.create(name: "Suomi", short: "fi", sortable_name: "su")
      indonesian = Language.create(name: "Bahasa Indonesia", short: "id", sortable_name: "ba")
      languages = Language.where(id: [german.id, finnish.id, indonesian.id])
      expect(languages.default_order).to eq([indonesian, german, finnish])
    end
  end

  describe "validations" do
    context "for :short" do
      it "shows 'Abbreviation' in error messages" do
        lang = build(:language, name: "Test Language", short: "toolong", sortable_name: "Test Language")
        lang.validate
        expect(lang.errors.full_messages).to include("Abbreviation is too long (maximum is 4 characters)")
      end
    end
  end
end
