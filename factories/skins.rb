require 'faker'
FactoryBot.define do

  factory :private_work_skin, class: Skin do
    author_id { FactoryBot.create(:user).id }
    title { Faker::Lorem.word }
    type { "WorkSkin" }
    public { false }

    factory :public_work_skin do
      public { true }
      official { true }
    end
  end
end
