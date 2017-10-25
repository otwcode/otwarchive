require 'spec_helper'

describe IndexSweeper do

  it "should index items that were expected but not found" do
    expect(AsyncIndexer).to receive(:index).with(Work, [2], "cleanup")

    IndexSweeper.async_cleanup(Work, [1,2], [1])
  end

end
