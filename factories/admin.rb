require 'faker'

FactoryGirl.define do
  factory :admin do
    login { generate(:login) }
    password "password"
    password_confirmation { |u| u.password }
    email
  end
end
