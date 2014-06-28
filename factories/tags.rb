require 'faker'
FactoryGirl.define do

  sequence(:tag_title) do |n|
    "Owned Tag Set #{n}"
  end

  sequence(:tag_name) do |n|
    "The #{n} Tag"
  end

  factory :owned_tag_set do
    title {generate(:tag_title)}
    nominated true
    after(:build) do |owned_tag_set|
      owned_tag_set.build_tag_set
      owned_tag_set.add_owner(FactoryGirl.create(:pseud))
    end
  end

  factory :tag_set_nomination do
    association :owned_tag_set
    association :pseud
  end

  factory :tag do
    canonical true
    name {generate(:tag_name)}
  end

  factory :unsorted_tag do
    sequence(:name) { |n| "Unsorted Tag #{n}"}
  end

  factory :fandom do
    canonical true
    sequence(:name) { |n| "The #{n} Fandom" }
  end

  factory :character do
    canonical true
    sequence(:name) { |n| "Character #{n}" }
  end

  factory :relationship do
    canonical true
    sequence(:name) { |n| "Jane#{n}/John#{n}" }
  end

  factory :freeform do
    canonical true
    sequence(:name) { |n| "Freeform #{n}" }
  end
end