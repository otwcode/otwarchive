require 'faker'
FactoryGirl.define do
  sequence(:tag_title) do |n|
    "Owned Tag Set #{n}"
  end

  sequence(:tag_name) do |n|
    "The #{n} Tag"
  end

  factory :common_tagging do
    association :common_tag, factory: :relationship
    association :filterable, factory: :fandom
  end

  factory :tag_set do
    tags { [create(:fandom)] }
  end

  factory :owned_tag_set do
    title { generate(:tag_title) }
    nominated true
    transient do
      owned_set_taggings { [create(:owned_set_tagging)] }
      owner { create(:pseud) }
      tags { [create(:fandom)] }
    end

    after(:build) do |owned_tag_set, evaluator|
      owned_tag_set.build_tag_set
      owned_tag_set.add_owner(evaluator.owner)
      owned_tag_set.fandom_nomination_limit = 2
      owned_tag_set.owned_set_taggings << evaluator.owned_set_taggings
      owned_tag_set.tags << evaluator.tags
    end
  end

  factory :owned_set_tagging do
    set_taggable { create(:prompt_restriction) }
  end

  factory :tag_set_nomination do
    association :owned_tag_set
    association :pseud
  end

  factory :tag_nomination do
    type 'FandomNomination'

    canonical true
    association :owned_tag_set

    after(:build) do |nomination|
      nomination.tagname = Fandom.last.name
    end
  end

  factory :tag do
    canonical true
    name { generate(:tag_name) }
  end

  factory :unsorted_tag do
    sequence(:name) { |n| "Unsorted Tag #{n}" }
  end

  factory :fandom do
    canonical true
    sequence(:name) { |n| "The #{n} Fandom" }
  end

  factory :character do
    canonical true
    sequence(:name) { |n| "Character #{n}" }
    common_taggings { [create(:common_tagging)] }
  end

  factory :relationship do
    canonical true
    sequence(:name) { |n| "Jane#{n}/John#{n}" }
  end

  factory :freeform do
    canonical true
    sequence(:name) { |n| "Freeform #{n}" }
  end

  factory :banned do |f|
    f.canonical true
    f.sequence(:name) { |n| "Banned #{n}" }
  end
end
