require 'faker'
FactoryBot.define do
  factory :skin do
    author_id { FactoryBot.create(:user).id }
    title { Faker::Lorem.word }

    trait :public do
      add_attribute(:public) { true }
      official { true }
    end
  end

  factory :work_skin do
    author_id { FactoryBot.create(:user).id }
    title { Faker::Lorem.word }

    trait :private do
      add_attribute(:public) { false }
    end

    trait :public do
      add_attribute(:public) { true }
      official { true }
    end
  end
end
