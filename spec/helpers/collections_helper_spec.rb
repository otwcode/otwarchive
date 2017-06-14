require 'spec_helper'

describe CollectionsHelper do

  describe "#show_collections_data" do

    before(:each) do
      @work = FactoryGirl.create(:work)
      @collection1 = FactoryGirl.create(:collection)
      @collection2 = FactoryGirl.create(:collection)
    end

    it "should return the collections a given work is in" do

      @work.collections << [@collection1, @collection2]

    end
  end

end
