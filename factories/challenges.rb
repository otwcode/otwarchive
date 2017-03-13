require 'faker'
FactoryGirl.define do
  factory :challenge_assignment do
    after(:build) do |assignment|
      assignment.collection_id = create(:collection, challenge: create(:gift_exchange)).id unless assignment.collection_id
      assignment.request_signup = create(:challenge_signup, collection_id: assignment.collection_id)
      assignment.offer_signup = create(:challenge_signup, collection_id: assignment.collection_id)
    end
  end

  factory :challenge_signup do
    assigned_as_request false
    assigned_as_offer false
    after(:build) do |signup|
      signup.pseud_id = create(:pseud).id unless signup.pseud_id
      signup.collection_id = create(:collection, challenge: create(:gift_exchange)).id unless signup.collection_id
      signup.offers.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
      signup.requests.build(pseud_id: signup.pseud_id, collection_id: signup.collection_id)
    end
  end

  factory :potential_match do
    after(:build) do |potential_match|
      potential_match.collection_id = create(:collection, challenge: create(:gift_exchange)).id unless potential_match.collection_id
      potential_match.offer_signup_id = create(:challenge_signup, collection_id: potential_match.collection_id)
      potential_match.request_signup_id = create(:challenge_signup, collection_id: potential_match.collection_id)
    end
  end

end
