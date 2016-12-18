# frozen_string_literal: true
require 'faker'

FactoryGirl.define do
  factory :api_key do
    name { "API key name" }
  end
end
