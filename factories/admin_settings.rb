require 'faker'

FactoryGirl.define do
  factory :admin_settings, class: AdminSetting do
    account_creation_enabled {true}
    invite_from_queue_at {Date.yesterday}
    invite_from_queue_enabled {true}
    invite_from_queue_number {10}
    invite_from_queue_frequency 1
    days_to_purge_unactivated {20}
    enable_test_caching {false}
  end
end