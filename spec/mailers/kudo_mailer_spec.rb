require 'spec_helper'

describe KudoMailer do
  describe "basic kudos emails" do

    before(:each) do
      @kudos = Factory.create(:kudo)
      @user = Factory.create(:user)
    end

    let(:email) { KudoMailer.kudo_notification(@user.id,@kudos.id).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      email.encoded.should =~ /#{text}/
    end
  end
end