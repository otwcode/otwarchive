require 'faker'

FactoryGirl.define do
  factory :gift do
    work { create(:work) }
    recipient "recipient"
  end
end