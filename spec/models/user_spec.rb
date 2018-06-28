require 'spec_helper'

describe User, :ready do

  describe "Create" do
    context "valid user" do

      let(:user) {build(:user)}
      it "should save a minimalistic user" do
        expect(user.save).to be_truthy
      end

      let(:user) {build(:user)}
      it "should encrypt password" do
        user.save
        expect(user.crypted_password).not_to be_empty
        expect(user.crypted_password).not_to eq(user.password)
      end

      let(:user) {build(:user)}
      it "should create default associateds" do
        user.save
        expect(user.profile).not_to be_nil
        expect(user.preference).not_to be_nil
        expect(user.pseuds.size).to eq(1)
        expect(user.pseuds.first.name).to eq(user.login)
        expect(user.pseuds.first.is_default).to be_truthy
      end

    end

    describe "User Validations" do
      context "missing age_over_13 flage" do
        let(:no_age_over_13) {build(:user, age_over_13: "0")}
        it "should not save user" do
          expect(no_age_over_13.save).to be_falsey
          expect(no_age_over_13.errors[:age_over_13]).not_to be_empty
        end
      end

      context "missing terms_of_service flag" do
        let(:no_tos) {build(:user, terms_of_service: "0")}
        it "should not save user" do
          expect(no_tos.save).to be_falsey
          expect(no_tos.errors[:terms_of_service]).not_to be_empty
        end
      end

      context "login length" do
        let(:login_short) {build(:user, login: 5)}
        it "should not save user with too short login" do
          expect(login_short.save).to be_falsey
          expect(login_short.errors[:login]).not_to be_empty
        end

        let(:login_long) {build(:user, login: 40)}
        it "should not save user with too long login" do
          expect(login_long.save).to be_falsey
          expect(login_long.errors[:login]).not_to be_empty
        end
      end

      context "email veracity" do
        BAD_EMAILS.each do |email|
          let(:bad_email) {build(:user, email: email)}
          it "cannot be created if the email does not pass veracity check" do
            expect(bad_email.save).to be_falsey
            expect(bad_email.errors[:email]).to include("should look like an email address.")
            expect(bad_email.errors[:email]).to include("does not seem to be a valid address.")
          end
        end
      end

      context "password length" do
        let(:password_short) {build(:user, password: 5)}
        it "should not save user with too short login" do
          expect(password_short.save).to be_falsey
          expect(password_short.errors[:password]).not_to be_empty
        end

        let(:password_long) {build(:user, password: 41)}
        it "should not save user with too long login" do
          expect(password_long.save).to be_falsey
          expect(password_long.errors[:password]).not_to be_empty
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
          expect(new.save).to be_falsey
          expect(new.errors[:login]).not_to be_empty
        end

        let(:new) {build(:duplicate_user, email: @existing.email)}
        it "should not save user when email exists already" do
          expect(new.save).to be_falsey
          expect(new.errors[:email]).not_to be_empty
        end

      end

    end

    describe "has_no_credentials?" do
      it "is true if password is blank" do
        @user = build(:user, password: nil)
        expect(@user.has_no_credentials?).to be_truthy
      end
      it "is false if password is not blank" do
        @user = build(:user)
        expect(@user.has_no_credentials?).to be_falsey
      end
    end

  end


end
