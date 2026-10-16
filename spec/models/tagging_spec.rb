require "spec_helper"

describe Tagging do
  it "can have an id larger than unsigned int" do
    tagging = build(:tagging, id: 5_294_967_295)

    expect(tagging).to be_valid
    expect(tagging.save).to be_truthy
  end
end
