require "spec_helper"
require "autocomplete_source"

shared_examples_for "an autocompleting tag" do
  context "without diacritics" do
    let(:auto) { described_class.new(name: "Autobot") }

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
        ac = REDIS_AUTOCOMPLETE.zrange("autocomplete_tag_fandom_completion", 0, -1)

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
        ac = REDIS_AUTOCOMPLETE.zrange("autocomplete_tag_fandom_completion", 0, -1)
        expect(ac).not_to include("#{auto.name.downcase},,")
      end
    end
  end

  context "with diacritics" do
    let(:auto) { described_class.new(name: "Âutobot2") }

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
        ac = REDIS_AUTOCOMPLETE.zrange("autocomplete_tag_fandom_completion", 0, -1)

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
        ac = REDIS_AUTOCOMPLETE.zrange("autocomplete_tag_fandom_completion", 0, -1)
        expect(ac).not_to include("#{ActiveSupport::Inflector.transliterate(auto.name.downcase)},,")
      end
    end
  end
end

shared_examples_for "an autocompletable class with a title" do
  let(:auto) { described_class.new(name: "Autobot", title: "Transformer") }

  it "has a search string composed of its name and title" do
    expect(auto.autocomplete_search_string).to eq("Autobot Transformer")
  end
end

describe Fandom do
  it_behaves_like "an autocompleting tag"
end

describe Collection do
  it_behaves_like "an autocompletable class with a title"
end
