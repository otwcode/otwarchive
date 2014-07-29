require 'faker'
FactoryGirl.define do

  factory :user_invite_requests, class: UserInviteRequest do
    user_id {FactoryGirl.create(:user).id}
    quantity {5}
    reason {"Because reasons!"}
    granted {false}
    handled {false}
  end
end