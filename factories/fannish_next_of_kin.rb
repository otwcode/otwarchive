require "faker"

FactoryBot.define do
  factory :fannish_next_of_kin do
    user { create(:user) }
    kin { create(:user) }
    kin_email { |u| u.kin.email }
  end
end
