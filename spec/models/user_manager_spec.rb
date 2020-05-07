require "spec_helper"

describe User do
  describe "#save" do
    context "denies random admin access" do
      let(:user) { create(:user) }
      let(:admin) { create(:admin) }

      it "returns error for admin without proper role" do
        manager = UserManager.new(admin, { user_login: user.login })
        expect(manager.save).to be_falsey
        expect(manager.errors).to eq ["Must have a valid admin role to proceed."]
      end
    end

    context "returns errors if params fields are missing" do
      let(:user) { create(:user) }
      let(:admin) { create(:admin, roles: ['policy_and_abuse']) }
      let(:next_of_kin) { create(:user) }

      it "returns error if user is missing" do
        manager = UserManager.new(admin, { user_login: nil })
        expect(manager.save).to be_falsey
        expect(manager.errors).to eq ["Must have a valid user and admin account to proceed."]
      end

      it "returns error if next of kin data is partially filled out" do
        manager = UserManager.new(admin, { user_login: user.login, next_of_kin_name: next_of_kin.login })
        expect(manager.save).to be_falsey
        expect(manager.errors).to eq ["Fannish next of kin email is missing."]
      end

      it "returns error if admin action present without note" do
        manager = UserManager.new(admin, {
          user_login: user.login, admin_action: 'suspend', suspend_days: '7' 
        })
        expect(manager.save).to be_falsey
        expect(manager.errors).to eq ["You must include notes in order to perform this action."]
      end

      it "returns error if suspension without time span" do
        manager = UserManager.new(admin, { 
          user_login: user.login, admin_action: 'suspend', admin_note: 'User violated community guidelines' 
        })
        expect(manager.save).to be_falsey
        expect(manager.errors).to eq ["Please enter the number of days for which the user should be suspended."]
      end

      it "returns error if invalid admin action" do
        manager = UserManager.new(admin, { user_login: user.login, admin_action: 'something_wicked' })
        expect(manager.save).to be_falsey
      end
    end

    context "allows save and succeeds with correct admin role and data" do
      let(:user) { create(:user) }
      let(:admin) { create(:admin, roles: ['policy_and_abuse']) }
      let(:next_of_kin) { create(:user) }

      it "succeeds if next of kin info is filled out" do
        manager = UserManager.new(admin, { 
          user_login: user.login,
          next_of_kin_name: next_of_kin.login,
          next_of_kin_email: next_of_kin.email
        })
        expect(manager.save).to be_truthy
        expect(manager.successes).to eq ["Fannish next of kin was updated."]
      end

      it "succeeds if suspension info is filled out" do
        manager = UserManager.new(admin, { 
          user_login: user.login,
          admin_action: 'suspend',
          suspend_days: '5',
          admin_note: 'User violated community guidelines'
        })
        expect(manager.save).to be_truthy
        expect(manager.successes).to eq ["User has been temporarily suspended."]
      end

      it "succeeds in banning user" do
        manager = UserManager.new(admin, { 
          user_login: user.login,
          admin_action: 'ban',
          admin_note: 'User violated community guidelines'
        })
        expect(manager.save).to be_truthy
        expect(manager.successes).to eq ["User has been permanently suspended."]
      end

      it "succeeds in unsuspending user" do
        user.update(suspended: true, suspended_until: 4.days.from_now)

        manager = UserManager.new(admin, { 
          user_login: user.login,
          admin_action: 'unsuspend',
          admin_note: 'There was a mistake in the review process'
        })
        expect(manager.save).to be_truthy
        expect(manager.successes).to eq ["Suspension has been lifted."]
      end

      it "succeeds in unbanning user" do
        user.update(banned: true)

        manager = UserManager.new(admin, { 
          user_login: user.login,
          admin_action: 'unban',
          admin_note: 'There was a mistake in the review process'
        })
        expect(manager.save).to be_truthy
        expect(manager.successes).to eq ["Suspension has been lifted."]
      end
    end
  end
end
