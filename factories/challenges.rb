require 'faker'
FactoryGirl.define do
  factory :challenge_assignment do
    after(:build) do |assignment|
      assignment.collection_id = FactoryGirl.create(:collection, challenge: GiftExchange.new).id unless assignment.collection_id
      assignment.request_signup = FactoryGirl.create(:challenge_signup, collection_id: assignment.collection_id)
      assignment.offer_signup = FactoryGirl.create(:challenge_signup, collection_id: assignment.collection_id)
    end
  end

  factory :challenge_signup do
    after(:build) do |signup|
      signup.pseud_id = FactoryGirl.create(:pseud).id unless signup.pseud_id
      signup.collection_id = FactoryGirl.create(:collection, challenge: GiftExchange.new).id unless signup.collection_id
      signup.offers.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
      signup.requests.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
    end
  end
  
  factory :potential_match do 
    after(:build) do |potential_match|
      potential_match.collection_id = FactoryGirl.create(:collection, challenge: GiftExchange.new).id unless potential_match.collection_id
      potential_match.offer_signup_id = FactoryGirl.create(:challenge_signup, collection_id: potential_match.collection_id)
      potential_match.request_signup_id = FactoryGirl.create(:challenge_signup, collection_id: potential_match.collection_id)
    end
  end  

  factory :gift_exchange do
    after(:build) do |ge|
      ge.offer_restriction_id = create(:prompt_restriction).id
      ge.request_restriction_id = create(:prompt_restriction).id
      ge.prompt_restriction_id = create(:prompt_restriction).id
    end
  end

  factory :offer
  factory :request

  factory :prompt_meme do
    after(:build) do |pm|
      pm.request_restriction_id = create(:prompt_restriction).id
      pm.prompt_restriction_id = create(:prompt_restriction).id
    end
  end
end
