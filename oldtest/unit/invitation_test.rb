require 'test_helper' 

class InvitationTest < ActiveSupport::TestCase
  context "an invitation" do
    setup do
      @invitation = create_invitation(:invitee_email => random_email)
    end
    should "have a generated token after it's created" do
      assert @invitation.token
    end
    
    context "after use" do
      setup do
        @user = create_user(:invitation_token => @invitation.token)
        @invitation.reload
      end
      should "be used up" do
        assert !@invitation.redeemed_at.nil?
      end
    end
  end

  context "an invitation created for an existing user" do
    should "not be valid" do      
      @user = create_user
      @invitation = new_invitation(:invitee_email => @user.email)
      assert !@invitation.valid?
      assert @invitation.errors.on("invitee_email")
    end
  end
end
