require 'faker'

FactoryGirl.define do
  factory :gift_exchange do
    request_restriction_id { FactoryGirl.create(:prompt_restriction).id }
    requests_num_allowed ArchiveConfig.PROMPTS_MAX
    requests_num_required 1
    offers_num_allowed ArchiveConfig.PROMPTS_MAX
    offers_num_required 1

    trait :open do
      signups_open_at Time.now - 1.day
      signups_close_at Time.now + 1.day
      signup_open true
    end

    trait :closed do
      signups_open_at Time.now - 2.days
      signups_close_at Time.now - 1.day
      signup_open false
    end
  end
end
