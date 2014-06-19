require 'spec_helper'

describe User, :ready do

  describe "Create" do
    context "valid user" do

      let(:user) {build(:user)}
      it "should save a minimalistic user" do
        user.save.should be_true
      end

      let(:user) {build(:user)}
      it "should encrypt password" do
        user.save
        user.crypted_password.should_not be_empty
        user.crypted_password.should_not == user.password
      end

      let(:user) {build(:user)}
      it "should create default associateds" do
        user.save
        user.profile.should_not be_nil
        user.preference.should_not be_nil
        user.pseuds.size.should == 1
        user.pseuds.first.name.should == user.login
        user.pseuds.first.is_default.should be_true
      end

    end

    describe "User Validations" do
      context "missing age_over_13 flage" do
        let(:no_age_over_13) {build(:user, age_over_13: "0")}
        it "should not save user" do
          no_age_over_13.save.should be_false
          no_age_over_13.errors[:age_over_13].should_not be_empty
        end
      end

      context "missing terms_of_service flag" do
        let(:no_tos) {build(:user, terms_of_service: "0")}
        it "should not save user" do
          no_tos.save.should be_false
          no_tos.errors[:terms_of_service].should_not be_empty
        end
      end

      context "login length" do
        let(:login_short) {build(:user, login: 5)}
        it "should not save user with too short login" do
          login_short.save.should be_false
          login_short.errors[:login].should_not be_empty
        end

        let(:login_long) {build(:user, login: 40)}
        it "should not save user with too long login" do
          login_long.save.should be_false
          login_long.errors[:login].should_not be_empty
        end
      end

      context "email veracity" do
        BAD_EMAILS.each do |email|
          let(:bad_email) {build(:user, email: email)}
          it "cannot be created if the email does not pass veracity check" do
            bad_email.save.should be_false
            bad_email.errors[:email].should include("should look like an email address.")
            bad_email.errors[:email].should include("does not seem to be a valid address.")
          end
        end
      end

      context "password length" do
        let(:password_short) {build(:user, password: 5)}
        it "should not save user with too short login" do
          password_short.save.should be_false
          password_short.errors[:password].should_not be_empty
        end

        let(:password_long) {build(:user, password: 41)}
        it "should not save user with too long login" do
          password_long.save.should be_false
          password_long.errors[:password].should_not be_empty
        end
      end

      context "login format validation" do
        let(:begins_with_symbol) {}
        let(:ends_with_symbol){}
        let(:correct_format) {}
      end

      context "login or email exists" do

        before :all do
          @existing = create(:user)
        end

        let(:new) {build(:user, login: @existing.login)}
        it "should not save user when login exists already" do
          new.save.should be_false
          new.errors[:login].should_not be_empty
        end

        let(:new) {build(:duplicate_user, email: @existing.email)}
        it "should not save user when email exists already" do
          new.save.should be_false
          new.errors[:email].should_not be_empty
        end

      end

    end

    describe "has_no_credentials?" do
      it "is true if password is blank" do
        @user = build(:user, password: nil)
        puts @user.password
        @user.has_no_credentials?.should be_true
      end
      it "is false if password is not blank" do
        @user = build(:user)
        @user.has_no_credentials?.should be_false
      end
    end

  end


end



