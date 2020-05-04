require 'faker'

FactoryBot.define do
  factory :admin do
    login { generate(:login) }
    password { "password" }
    password_confirmation { |u| u.password }
    email

    factory :superadmin do
      login { "superadmin" }
      password { "IHaveThePower" }
      roles { ["superadmin"] }
    end
  end

  factory :admin_activity do
    admin
    action { "update_tags" }
    summary { "MyActivity" }
  end
end
