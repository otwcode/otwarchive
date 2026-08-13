require 'spec_helper'

describe Query do
  describe "#search" do
    context "when Elasticsearch raises a BadRequest error" do
      before do
        allow($elasticsearch).to receive(:search)
          .and_raise(Elastic::Transport::Transport::Errors::BadRequest)
      end

      it "returns an error hash" do
        result = Query.new.search
        expect(result).to eq(error: "Your search failed because of a syntax error. Please try again.")
      end

      it "reports the exception to Sentry" do
        sentry = class_double("Sentry", capture_exception: nil).as_stubbed_const
        Query.new.search
        expect(sentry).to have_received(:capture_exception)
          .with(instance_of(Elastic::Transport::Transport::Errors::BadRequest))
      end
    end
  end

  describe '#split_query_text_phrases' do
    it "should add quoted phrases to a query string" do
      q = Query.new
      result = q.split_query_text_phrases(:tag, "bork bork bork")
      expect(result).to eq(" tag:\"bork bork bork\"")
    end

    it "should separate phrases by comma" do
      q = Query.new
      result = q.split_query_text_phrases(:tag, "unicorns, i love turnips")
      expect(result).to eq(" tag:\"unicorns\" tag:\"i love turnips\"")
    end
  end

  describe '#split_query_text_words' do
    it "should add individual words to a query string" do
      q = Query.new
      result = q.split_query_text_words(:notes, "carrots celery potato")
      expect(result).to eq(" notes:carrots notes:celery notes:potato")
    end

    it "should replace minuses with NOTs" do
      q = Query.new
      result = q.split_query_text_words(:hero, "superman -batman")
      expect(result).to eq(" hero:superman NOT hero:batman")
    end

    it "should not touch stand-alone minuses" do
      q = Query.new
      result = q.split_query_text_words(:title, "foo - bar")
      expect(result).to eq(" title:foo title:\\- title:bar")
    end
  end
end
