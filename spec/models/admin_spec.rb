#require 'spec_helper'
#
#describe Admin do
#
#
#  it "can be created" do
#    create(:admin).should be_valid
#  end
#
#  context "invalid" do
#
#    let(:admin_without_login) {attributes_for(:admin, login: nil)}
#    it 'is invalid without a user name' do
#      admin_without_login.save.should be_false
#      admin_without_login.
#    end
#
#    it 'is invalid without an email address' do
#      build(:admin, email: nil).should be_invalid
#    end
#
#    it 'is invalid without a password' do
#      build(:admin, password: nil).should be_invalid
#    end
#
#    it 'is invalid without a password confirmation' do
#      build(:admin, password_confirmation: nil).should be_invalid
#    end
#  end
#
#  context "length of login" do
#
#    let(:too_short) {Faker::Lorem.characters(ArchiveConfig.LOGIN_LENGTH_MIN -1)}
#     it "is invalid if under 6 characters" do
#       build(:admin, login: too_short).should be_invalid
#     end
#
#     let(:too_long) {Faker::Lorem.characters(ArchiveConfig.LOGIN_LENGTH_MAX + 1)}
#     it "is invalid if over 40 characters" do
#       build(:admin, login: too_long).should be_invalid
#     end
#  end
#
#  context "length of password" do
#
#    let(:too_short) {Faker::Lorem.characters(ArchiveConfig.PASSWORD_LENGTH_MIN - 1)}
#    it "is invalid if under 3 characters" do
#      build(:admin, password: too_short).should be_invalid
#    end
#
#    let(:too_long) {Faker::Lorem.characters(ArchiveConfig.PASSWORD_LENGTH_MIN + 1)}
#    it "is invalid if over 40 characters" do
#      build(:admin, password: too_long).should be_invalid
#    end
#  end
#
#  context "uniqueness" do
#    let(:existing_user) {create(:admin)}
#
#    it "is invalid if login is not unique" do
#      build(:admin, login: existing_user.login).should be_invalid
#    end
#
#    it "is invalid if email already exists" do
#      build(:admin, email: existing_user.email).should be_invalid
#    end
#
#  end
#end