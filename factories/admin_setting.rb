require 'faker'

FactoryBot.define do
  factory :admin_setting do
    account_creation_enabled { 1 }
    creation_requires_invite { 1 }
    request_invite_enabled { 0 }
    invite_from_queue_enabled { 1 }
    invite_from_queue_number { 10 }
    invite_from_queue_frequency { 7 }
    days_to_purge_unactivated { 7 }
    disable_support_form { 0 }
    disabled_support_form_text { "" }
    suspend_filter_counts { 0 }
    tag_wrangling_off { 0 }
    downloads_enabled { 1 }
    enable_test_caching { 0 }
    cache_expiration { 10 }
    hide_spam { 1 }
    last_updated_by { FactoryBot.create(:admin).id }
  end
end
