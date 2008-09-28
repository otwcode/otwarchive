require File.dirname(__FILE__) + '/../test_helper' 

class InvitationTest < ActiveSupport::TestCase
  context "an invitation" do
    setup do
      @invitation = create_invitation(:recipient_email => random_email)
    end
    should_require_attributes :recipient_email
    should "not have an existing user as a recipient" do
      @user = create_user
      @invitation.recipient_email = @user.email
      assert !@invitation.valid?
      assert @invitation.errors.on("recipient_email")
    end
    should "have a generated token after it's created" do
      assert @invitation.token
    end
    
    context "with a sender" do
      setup do
        @user = create_user
        @invitation.sender = @user
      end
      should "be created if the sender's invitation limit is greater than zero" do
        assert @user.invitation_limit == 1        
        assert @invitation.valid?
      end
      should "decrement the sender's invitation limit when it's created" do
        limit = @user.invitation_limit
        @invitation = create_invitation(:recipient_email => random_email, :sender => @user)
        assert @user.invitation_limit == limit - 1
      end
      should "not be created if the sender's invitation limit is less than one" do
        @user.update_attribute(:invitation_limit, 0)
        assert !@invitation.valid?
      end
    end
  end
end
