require 'spec_helper'

describe AdminBlacklistedEmail, :ready do

  it "can be created" do
    expect(create(:admin_blacklisted_email)).to be_valid
  end

  context "invalid" do
    let(:blacklisted_without_email) {build(:admin_blacklisted_email, email: nil)}
    it 'is invalid without an email' do
      expect(blacklisted_without_email.save).to be_falsey
      expect(blacklisted_without_email.errors[:email]).not_to be_empty
    end
  end

  context "uniqueness" do
    let(:existing_email) {create(:admin_blacklisted_email, email: "foobar@gmail.com")}

    it "is invalid if email is not unique" do
      expect(build(:admin_blacklisted_email, email: existing_email.email)).to be_invalid
    end
  end
    
  context "blacklisted emails" do
    let(:existing_email) {create(:admin_blacklisted_email, email: "foobar@gmail.com")}    
    
    it "match themselves" do
      expect(AdminBlacklistedEmail.is_blacklisted?("foobar@gmail.com"))
    end
    
    it "match variants" do
      expect(AdminBlacklistedEmail.is_blacklisted?("FOOBAR@gmail.com")).to be_truthy
      expect(AdminBlacklistedEmail.is_blacklisted?("foobar+baz@gmail.com")).to be_truthy
      expect(AdminBlacklistedEmail.is_blacklisted?("foo.bar@gmail.com")).to be_truthy
      expect(AdminBlacklistedEmail.is_blacklisted?("foobar@googlemail.com")).to be_truthy
    end
  end
end
