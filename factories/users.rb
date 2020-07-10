require 'faker'

FactoryBot.define do
  sequence(:login) do |n|
    "#{Faker::Lorem.characters(8)}#{n}"
  end

  sequence :email do |n|
    Faker::Internet.email(name="#{Faker::Name.first_name}_#{n}")
  end
  sequence :admin_login do |n|
    "testadmin#{n}"
  end

  factory :role do
    name { Faker::Book.genre }
  end

  factory :user do
    login { generate(:login) }
    password { "password" }
    age_over_13 { '1' }
    terms_of_service { '1' }
    password_confirmation { |u| u.password }
    email { generate(:email) }

    factory :invited_user do
      login { generate(:login) }
      invitation_token { nil }
    end

    factory :opendoors_user do
      roles { [create(:role, name: "opendoors")] }
    end
    
    factory :archivist do
      roles { [ Role.find_or_create_by(name: "archivist")] }
    end
  end
end
