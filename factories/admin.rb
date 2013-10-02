require 'faker'

FactoryGirl.define do
  factory :admin do
    login
    password "password"
    password_confirmation { |u| u.password }
    email
  end
end