require "spec_helper"

describe UserManager do
  describe "#save" do
    let(:admin) { create(:admin) }
    let(:next_of_kin) { create(:user) }
    let(:user) { create(:user) }

    it "returns error without user" do
      manager = UserManager.new(admin, user_login: nil)
      expect(manager.save).to be_falsey
      expect(manager.errors).to eq ["Must have a valid user and admin account to proceed."]
    end

    it "returns error if next of kin email is missing" do
      manager = UserManager.new(admin, user_login: user.login, next_of_kin_name: next_of_kin.login)
      expect(manager.save).to be_falsey
      expect(manager.errors).to eq ["Fannish next of kin email is missing."]
    end

    it "returns error if notes are missing when suspending" do
      manager = UserManager.new(admin, user_login: user.login, admin_action: "suspend", suspend_days: "7")
      expect(manager.save).to be_falsey
      expect(manager.errors).to eq ["You must include notes in order to perform this action."]
    end

    it "returns error for suspension without time span" do
      manager = UserManager.new(admin, user_login: user.login, admin_action: "suspend", admin_note: "User violated community guidelines")
      expect(manager.save).to be_falsey
      expect(manager.errors).to eq ["Please enter the number of days for which the user should be suspended."]
    end

    it "returns error for invalid admin actions" do
      manager = UserManager.new(admin, user_login: user.login, admin_action: "something_wicked")
      expect(manager.save).to be_falsey
    end

    it "succeeds with next of kin info" do
      manager = UserManager.new(admin, user_login: user.login, next_of_kin_name: next_of_kin.login, next_of_kin_email: next_of_kin.email)
      expect(manager.save).to be_truthy
      expect(manager.successes).to eq ["Fannish next of kin was updated."]
    end

    it "succeeds in suspending user" do
      manager = UserManager.new(admin, user_login: user.login, admin_action: "suspend", suspend_days: "5", admin_note: "User violated community guidelines")
      expect(manager.save).to be_truthy
      expect(manager.successes).to eq ["User has been temporarily suspended."]
    end

    it "succeeds in banning user" do
      manager = UserManager.new(admin, user_login: user.login, admin_action: "ban", admin_note: "User violated community guidelines")
      expect(manager.save).to be_truthy
      expect(manager.successes).to eq ["User has been permanently suspended."]
    end

    it "succeeds in unsuspending user" do
      user.update(suspended: true, suspended_until: 4.days.from_now)
      manager = UserManager.new(admin, user_login: user.login, admin_action: "unsuspend", admin_note: "There was a mistake in the review process")
      expect(manager.save).to be_truthy
      expect(manager.successes).to eq ["Suspension has been lifted."]
    end

    it "succeeds in unbanning user" do
      user.update(banned: true)
      manager = UserManager.new(admin, user_login: user.login, admin_action: "unban", admin_note: "There was a mistake in the review process")
      expect(manager.save).to be_truthy
      expect(manager.successes).to eq ["Suspension has been lifted."]
    end
  end
end
