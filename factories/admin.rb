require 'faker'

FactoryBot.define do
  factory :admin do
    login { generate(:login) }
    password { "password" }
    password_confirmation { |u| u.password }
    email
  end

  factory :admin_activity do
    admin
    action { "update_tags" }
    summary { "MyActivity" }
  end
end
