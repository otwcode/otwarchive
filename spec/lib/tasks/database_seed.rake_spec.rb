require "spec_helper"

describe "rake db:fixtures:load" do
  before do
    WebMock.stub_request(:any, /example/)
  end

  after do
    WebMock.reset!
  end

  it "should result in valid records" do
    subject.invoke

    # Make sure all subclasses are present in ApplicationRecord.descendants
    Rails.application.eager_load!

    ApplicationRecord.descendants.each do |model|
      model.all.each do |record|
        expect(record).to be_valid
      end
    end
  end
end
