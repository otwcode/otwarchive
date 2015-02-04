require 'spec_helper'

describe KudoMailer do
  describe "basic kudos emails" do

    before(:each) do
      @kudos = FactoryGirl.create(:kudo)
      @user = FactoryGirl.create(:user)
    end

    let(:email) { KudoMailer.kudo_notification(@user.id, @kudos.id).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end
