require 'spec_helper'

describe ChallengeSignupsController, type: :controller do

  let(:tag_set1) { create(:tag_set) }
  let(:signup) { create(:challenge_signup) }

  describe "gift_exchange_to_csv" do
    let(:tag_set2) { create(:tag_set) }
    let(:gift_exchange) { create(:gift_exchange) }
    let(:collection) { create(:collection,
                              challenge: gift_exchange,
                              challenge_type: "GiftExchange",
                              signups: [signup]) }

    before do
      signup.offers = [create(:offer,
                              collection_id: collection.id,
                              challenge_signup_id: signup.id,
                              tag_set: tag_set1)]
      signup.requests = [create(:request,
                                collection_id: collection.id,
                                challenge_signup_id: signup.id,
                                tag_set: tag_set2)]
    end

    it "generates a CSV with all the challenge information" do
      controller.instance_variable_set(:@challenge, collection.challenge)
      controller.instance_variable_set(:@collection, collection)
      expect(controller.send(:gift_exchange_to_csv))
        .to eq([["Pseud", "Email", "Sign-up URL", "Request 1 Tags", "Request 1 Description", "Offer 1 Tags", "Offer 1 Description"],
                [signup.pseud.name, signup.pseud.user.email, collection_signup_url(collection, signup),
                 signup.requests.first.tag_set.tags.first.name, "", signup.offers.first.tag_set.tags.first.name, ""]])
    end
  end

  describe "prompt_meme_to_csv" do
    let(:prompt_meme) { create(:prompt_meme) }
    let(:collection) { create(:collection,
                              challenge: prompt_meme,
                              challenge_type: "PromptMeme",
                              signups: [signup]) }

    before do
      signup.requests = [create(:request,
                                collection_id: collection.id,
                                challenge_signup_id: signup.id,
                                tag_set: tag_set1)]
    end

    it "generates a CSV with all the challenge information" do
      controller.instance_variable_set(:@challenge, collection.challenge)
      controller.instance_variable_set(:@collection, collection)
      expect(controller.send(:prompt_meme_to_csv))
        .to eq([["Pseud", "Email", "Sign-up URL", "Tags", "Description"],
                [signup.pseud.name, signup.pseud.user.email, collection_signup_url(collection, signup),
                 signup.requests.first.tag_set.tags.first.name, ""]])
    end
  end
end
