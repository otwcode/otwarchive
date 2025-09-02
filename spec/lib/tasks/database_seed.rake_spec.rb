require "spec_helper"

describe "rake db:fixtures:load" do
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
