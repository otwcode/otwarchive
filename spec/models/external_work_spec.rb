require 'spec_helper'

describe ExternalWork do

  context "invalid url" do
    INVALID_URLS.each do |url|
      let(:invalid_url) {build(:external_work, url: url)}
      it "is not saved" do
        invalid_url.save.should be_false
        invalid_url.errors[:url].should_not be_empty
        invalid_url.errors[:url].should include("does not appear to be a valid URL.")
      end
    end
  end


  context "inactive url" do
    INACTIVE_URLS.each do |url|
      let(:inactive_url) {build(:external_work, url: url)}
      it "is not saved" do
        inactive_url.save.should be_false
        inactive_url.errors[:url].should include("could not be reached. If the URL is correct and the site is currently down, please try again later.")
      end
    end
  end

  context "valid urls" do
    URLS = ["http://the--ivorytower.livejournal.com/153798.html"]

    URLS.each do |url|
      let(:valid_url) {build(:external_work, url: url)}
      it "saves the external work" do
        valid_url.save.should be_true
      end
    end
  end

end