require "spec_helper"
require "autocomplete_source"

shared_examples_for "an autocompleting tag" do
  context "without diacritics" do
    let(:auto) { FactoryBot.create(:tag, name: "Autobot", type: tag_type) }

    describe "#autocomplete_prefixes" do
      it "returns an array that includes the class name" do
        expect(auto.autocomplete_prefixes).to include("autocomplete_tag_all")
      end
    end

    describe "#autocomplete_search_string" do
      it "is equal to its name" do
        expect(auto.autocomplete_search_string).to eq(auto.name)
      end
    end

    describe "#autocomplete_value" do
      it "includes id and name" do
        expect(auto.autocomplete_value).to eq("#{auto.id}: #{auto.name}")
      end
    end

    describe "#autocomplete_score" do
      it "returns zero" do
        expect(auto.autocomplete_score).to eq(0)
      end
    end

    describe "#add_to_autocomplete" do
      it "adds itself to the autocomplete" do
        auto.add_to_autocomplete
        ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)

        (1..ac.length).each do |i|
          search_string = auto.name.downcase.slice(0, i)
          expect(ac).to include(search_string.to_s)
        end

        expect(ac).to include("#{auto.name.downcase},,")
      end
    end

    describe "#remove_from_autocomplete" do
      it "removes itself from the autocomplete" do
        auto.add_to_autocomplete
        auto.remove_from_autocomplete
        ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)
        expect(ac).not_to include("#{auto.name.downcase},,")
      end
    end
  end

  context "with diacritics" do
    let(:auto) { FactoryBot.create(:tag, name: "Àutobot2", type: tag_type) }

    describe "#autocomplete_search_string" do
      it "is equal to its name" do
        expect(auto.autocomplete_search_string).to eq(ActiveSupport::Inflector.transliterate(auto.name))
      end
    end

    describe "#autocomplete_value" do
      it "includes id and name" do
        expect(auto.autocomplete_value).to eq("#{auto.id}: #{auto.name}")
      end
    end

    describe "#add_to_autocomplete" do
      it "adds itself to the autocomplete" do
        auto.add_to_autocomplete
        ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)

        (1..ac.length).each do |i|
          search_string = ActiveSupport::Inflector.transliterate(auto.name.downcase.slice(0, i))
          expect(ac).to include(search_string.to_s)
        end

        expect(ac).to include("#{ActiveSupport::Inflector.transliterate(auto.name.downcase)},,")
      end
    end

    describe "#remove_from_autocomplete" do
      it "removes itself from the autocomplete" do
        auto.add_to_autocomplete
        auto.remove_from_autocomplete
        ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)
        expect(ac).not_to include("#{ActiveSupport::Inflector.transliterate(auto.name.downcase)},,")
      end
    end
  end
end

describe Fandom do
  let(:tag_type) { "Fandom" }
  let(:autocomplete_cache_key) { "autocomplete_tag_fandom_completion" }
  
  it_behaves_like "an autocompleting tag"
end

describe Collection do
  # Note that collection name must be URL-safe (hence the diacritic on the title)
  let(:auto) { FactoryBot.create(:collection, name: "Transformer", title: "Àutobot") }
  let(:autocomplete_cache_key) { "autocomplete_collection_all_completion" }

  describe "#autocomplete_search_string" do
    it "has a search string composed of its name and title" do
      expect(auto.autocomplete_search_string).to eq("#{auto.name} #{auto.title}")
    end
  end

  describe "#add_to_autocomplete" do
    it "adds itself to the autocomplete" do
      auto.add_to_autocomplete
      ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)

      [auto.name, auto.title].each do |search_param|
        (1..search_param.length).each do |i|
          search_string = ActiveSupport::Inflector.transliterate(search_param.downcase.slice(0, i))
          expect(ac).to include(search_string.to_s)
        end

        expect(ac).to include("#{ActiveSupport::Inflector.transliterate(search_param.downcase)},,")
      end
    end
  end

  describe "#remove_from_autocomplete" do
    it "removes itself from the autocomplete" do
      auto.add_to_autocomplete
      auto.remove_from_autocomplete
      ac = REDIS_AUTOCOMPLETE.zrange(autocomplete_cache_key, 0, -1)
      expect(ac).not_to include("#{ActiveSupport::Inflector.transliterate(auto.name.downcase)},,")
      expect(ac).not_to include("#{ActiveSupport::Inflector.transliterate(auto.title.downcase)},,")
    end
  end
end
