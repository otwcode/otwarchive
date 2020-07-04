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

    factory :policy_and_abuse_admin do
      login { "policy_admin" }
      password { "policy" }
      roles { ["policy_and_abuse"] }
    end

    factory :support_admin do
      login { "support_admin" }
      password { "support" }
      roles { ["support"] }
    end

    factory :tag_wrangling_admin do
      login { "tag_wrangling_admin" }
      password { "tagwrangling" }
      roles { ["tag_wrangling"] }
    end

    factory :open_doors_admin do
      login { "open_doors_admin" }
      password { "opendoors" }
      roles { ["open_doors"] }
    end
  end

  factory :admin_activity do
    admin
    action { "update_tags" }
    summary { "MyActivity" }
  end
end
