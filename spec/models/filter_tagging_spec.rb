require "spec_helper"

describe FilterTagging do
  it "can have an id larger than unsigned int" do
    filter_tagging = build(:filter_tagging, id: 5_294_967_295)

    expect(filter_tagging).to be_valid
    expect(filter_tagging.save).to be_truthy
  end
end
