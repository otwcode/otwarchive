require "spec_helper"

describe AdminPostHelper do
  describe "#sorted_translations" do
    let(:english) { Language.find_by(short: "en", sortable_name: "") }
    let(:german) { create(:language, name: "Deutsch", short: "de", sortable_name: "") }
    let(:finnish) { create(:language, name: "Suomi", short: "fi", sortable_name: "su") }
    let(:indonesian) { create(:language, name: "Bahasa Indonesia", short: "id", sortable_name: "ba") }

    let(:english_post) { create(:admin_post, language: english) }

    it "returns translations sorted alphabetically by language" do
      german_post = create(:admin_post, language: german, translated_post: english_post)
      finnish_post = create(:admin_post, language: finnish, translated_post: english_post)
      indonesian_post = create(:admin_post, language: indonesian, translated_post: english_post)

      expect(sorted_translations(english_post.reload)).to eq([indonesian_post, german_post, finnish_post])
    end

    context "when the news is posted" do
      it "does not include draft translations" do
        create(:admin_post, :draft, language: german, translated_post: english_post)
        finnish_post = create(:admin_post, language: finnish, translated_post: english_post)
        create(:admin_post, :draft, language: indonesian, translated_post: english_post)

        expect(sorted_translations(english_post.reload)).to eq([finnish_post])
      end
    end

    context "when the news is a draft" do
      let(:english_post) { create(:admin_post, :draft, language: english) }

      it "includes draft translations" do
        german_post = create(:admin_post, :draft, language: german, translated_post: english_post)
        finnish_post = create(:admin_post, :draft, language: finnish, translated_post: english_post)
        indonesian_post = create(:admin_post, :draft, language: indonesian, translated_post: english_post)

        expect(sorted_translations(english_post.reload)).to eq([indonesian_post, german_post, finnish_post])
      end
    end
  end
end
