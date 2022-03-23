FactoryBot.define do
  factory :kudo do
    commentable { create(:work) }
  end
end
