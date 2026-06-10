require "faker"

FactoryBot.define do
  sequence(:collection_name) do |n|
    "basic_collection_#{n}"
  end

  sequence(:collection_title) do |n|
    "Basic Collection #{n}"
  end

  factory :collection_participant do
    pseud
    participant_role { "Owner" }
  end

  factory :collection_preference do |f|
  end

  factory :collection_profile do |f|
  end

  factory :collection do |f|
    name { generate(:collection_name) }
    title { generate(:collection_title) }

    transient do
      owner { build(:pseud) }
    end

    after(:build) do |collection, evaluator|
      collection.collection_participants.build(pseud: evaluator.owner, participant_role: "Owner")
    end

    factory :anonymous_collection do
      association :collection_preference, anonymous: true
    end

    factory :unrevealed_collection do
      association :collection_preference, unrevealed: true
    end

    factory :anonymous_unrevealed_collection do
      association :collection_preference, unrevealed: true, anonymous: true
    end

    trait :closed do
      association :collection_preference, closed: true
    end

    trait :moderated do
      association :collection_preference, moderated: true
    end
  end

  factory :collection_item do
    item_type { "Work" }
    collection
  end
end
