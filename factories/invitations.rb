require 'faker'

FactoryGirl.define do

  factory :invite_request do
    email
  end

  factory :invitation do
    invitee_email "default@email.com"
  end

end