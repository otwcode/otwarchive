require 'spec_helper'

describe CollectionMailer do
  describe "basic collection emails" do

    before(:each) do
      @collection = Collection.new
      @work = Work.new
    end

    let(:email) { CollectionMailer.item_added_notificationn(@work,@collection).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      email.encoded.should =~ /#{text}/
    end
  end
end