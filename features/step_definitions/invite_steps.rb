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
  step %{I have no users}
    step %{I have an AdminSetting}
    step %{I am logged in as "user1"}
end

### WHEN

When /^I turn on the invitation queue$/ do
  step "I am logged in as an admin"
  step %{I go to the admin-settings page}
      step %{I check "admin_setting_invite_from_queue_enabled"}
      step %{I press "Update"}
end

When /^I turn off the invitation queue$/ do
  step "I am logged in as an admin"
  step %{I go to the admin-settings page}
      step %{I uncheck "admin_setting_invite_from_queue_enabled"}
      step %{I press "Update"}
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
  step %{I am logged in as "user1"}
      step %{I go to the homepage}
    step %{I follow "Invite a friend"}
end

When /^I try to invite a friend from my user page$/ do
  step %{I am logged in as "user1"}
      step %{I go to my user page}
    step %{I follow "Invitations"}
end

When /^I request some invites$/ do
  step %{I try to invite a friend from my user page}
    step %{I follow "Request more"}
    step %{I fill in "user_invite_request_quantity" with "3"}
      step %{I fill in "user_invite_request_reason" with "I want them for a friend"}
      step %{I press "Send Request"}
end

When /^I view requests as an admin$/ do
  step %{I am logged in as an admin}
    step %{I follow "Invitations"}
      step %{I follow "Manage requests"}
end

When /^an admin grants the request$/ do
  step %{I view requests as an admin}
    step %{I fill in "requests[user1]" with "2"}
      step %{I press "Update"}
end
