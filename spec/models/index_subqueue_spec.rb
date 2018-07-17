require 'spec_helper'


describe IndexSubqueue do
  let(:subqueue) { IndexSubqueue.new("index:work:main:1234567:0") }

  it "should have ids added to it" do
    subqueue.add_ids([1,2,3,4])
    expect(subqueue.ids).to eq(%w(1 2 3 4))
  end

  it "should get its target class from the name" do
    expect(subqueue.klass).to eq(Work)
  end

  it "should get its label from the name" do
    expect(subqueue.label).to eq("main")
  end
end
