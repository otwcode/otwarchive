### GIVEN

Given /^an invitation(?: for "([^\"]+)") exists$/ do |invitee_email|
  invite = Invitation.new
  invite.invitee_email = (invitee_email ? invitee_email : "default@example.org")
  invite.save
end

def invite(attributes = {})
  @invite ||= Invitation.new
  @invite.invitee_email = "default@example.org"
  @invite.save  
  @invite
end

Given /^I have invitations set up$/ do
  Given %{I have no users}
    And %{I have an AdminSetting}
    And %{I am logged in as "user1"}
end

### WHEN

When /^I turn on the invitation queue$/ do
  When "I am logged in as an admin"
  When %{I follow "settings"}
      And %{I check "admin_setting_invite_from_queue_enabled"}
      And %{I press "Update"}
end

When /^I turn off the invitation queue$/ do
  When "I am logged in as an admin"
  When %{I follow "settings"}
      And %{I uncheck "admin_setting_invite_from_queue_enabled"}
      And %{I press "Update"}
end

When /^I use an invitation to sign up$/ do
  visit signup_path(invite.token)
end

When /^I use an already used invitation to sign up$/ do
  steps %Q{
    Given the following activated user exists
      | login    | password |
      | invited  | password |
  }
  user = User.find_by_login("invited")
  invite.redeemed_at = Time.now
  invite.mark_as_redeemed(user)
  invite.save
  visit signup_path(invite.token)
end

When /^I try to invite a friend from the homepage$/ do
  When %{I am logged in as "user1"}
      And %{I go to the homepage}
    When %{I follow "INVITE A FRIEND"}
end

When /^I try to invite a friend from my user page$/ do
  When %{I am logged in as "user1"}
      And %{I go to my user page}
    When %{I follow "Invitations"}
end

When /^I request some invites$/ do
  When %{I try to invite a friend from my user page}
    When %{I follow "Request more"}
    When %{I fill in "user_invite_request_quantity" with "3"}
      And %{I fill in "user_invite_request_reason" with "I want them for a friend"}
      And %{I press "Create"}
end
