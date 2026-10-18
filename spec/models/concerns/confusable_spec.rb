require "spec_helper"

describe Confusable do
  context "in confusable check" do
    it "classifies the word itself as confusable" do
      expect(Confusable.confusable?("Support", "Support")).to be_truthy
    end

    it "separates the characters for confusables with combined characters" do
      expect(Confusable.confusable?("admin", "adrnin")).to be_truthy
    end

    it "removes default ignorable code points" do
      # ZERO WIDTH NON-JOINER, U+200C
      expect(Confusable.confusable?("𝅳\u200c", "")).to be_truthy
    end

    it "classifies two words with a cyrillic/latin difference as confusable" do
      expect(Confusable.confusable?("SupРort", "Support")).to be_truthy
    end

    it "removes punctuations" do
      expect(Confusable.confusable?("Sup.port", "Support")).to be_truthy
    end

    it "removes blank characters" do
      expect(Confusable.confusable?("Sup port", "Support")).to be_truthy
    end

    it "removes dialectics" do
      expect(Confusable.confusable?("Suppört", "Support")).to be_truthy
    end

    context "uppercase/lowercase issues" do
      it "both I and i resolves to l" do
        expect(Confusable.confusable?("I", "i")).to be_truthy
      end

      it "m resolves to rn" do
        expect(Confusable.confusable?("m", "rn")).to be_truthy
      end

      it "I resolves to l" do
        expect(Confusable.confusable?("I", "l")).to be_truthy
      end

      it "i resolves to L" do
        expect(Confusable.confusable?("i", "L")).to be_truthy
      end
    end
  end
end
