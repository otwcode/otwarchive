FactoryBot.define do
  factory :work_original_creator do
    work
    user_id { create(:user).id }
  end
end
