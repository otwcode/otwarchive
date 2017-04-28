require 'faker'

FactoryGirl.define do
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
  end

  factory :user do
    login {generate(:login)}
    password "password"
    age_over_13 '1'
    terms_of_service '1'
    password_confirmation { |u| u.password }
    email {generate(:email)}


    factory :duplicate_user do
      login nil
      email nil
    end

    factory :invited_user do
      login {generate(:login)}
      invitation_token nil
    end

    factory :opendoors_user do
      roles { [create(:role, name: "opendoors")] }
    end
  end
end