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
