require 'faker'
FactoryBot.define do
  factory :work_skin do
    author_id { FactoryBot.create(:user).id }
    title { Faker::Lorem.word }

    trait :private do
      public { false }
    end

    trait :public do
      public { true }
      official { true }
    end
  end
end
