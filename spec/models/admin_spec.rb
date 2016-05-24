require 'spec_helper'

describe Admin, :ready do


  it "can be created" do
    expect(create(:admin)).to be_valid
  end

  context "invalid" do

    let(:admin_without_login) {build(:admin, login: nil)}
    it 'is invalid without a user name' do
      expect(admin_without_login.save).to be_falsey
      expect(admin_without_login.errors[:login]).not_to be_empty
    end

    it 'is invalid without an email address' do
      expect(build(:admin, email: nil)).to be_invalid
    end

    it 'is invalid without a password' do
      expect(build(:admin, password: nil)).to be_invalid
    end

    it 'is invalid without a password confirmation' do
      expect(build(:admin, password_confirmation: nil)).to be_invalid
    end
  end
  #
  #context "length of login" do
  #
  #  let(:login_too_short) {build(:admin, login: Faker::Lorem.characters(2))}
  #  it "is invalid if under 3 characters" do
  #    login_too_short.save.should be_false
  #    login_too_short.errors[:login].should_not be_empty
  #  end
  #
  #  let(:login_too_long) {build(:admin, login: Faker::Lorem.characters(41))}
  #  it "is invalid if over 40 characters" do
  #    login_too_long.save.should be_false
  #    login_too_long.errors[:login].should_not be_empty
  #  end
  #end
  #
  #context "length of password" do
  #
  #  let(:password_too_short) {build(:admin, password: Faker::Lorem.characters(5))}
  #  it "is invalid if under 6 characters" do
  #    password_too_short.save.should be_false
  #    password_too_short.errors[:password].should_not be_empty
  #  end
  #
  #  let(:password_too_long) {build(:admin, password: Faker::Lorem.characters(41))}
  #  it "is invalid if over 40 characters" do
  #    password_too_long.save.should be_false
  #    password_too_long.errors[:password].should be_empty
  #  end
  #end

  context "uniqueness" do
    let(:existing_user) {create(:admin)}

    it "is invalid if login is not unique" do
      expect(build(:admin, login: existing_user.login)).to be_invalid
    end

    it "is invalid if email already exists" do
      expect(build(:admin, email: existing_user.email)).to be_invalid
    end

  end
end