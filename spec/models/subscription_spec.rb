require 'spec_helper'

describe Subscription do
  let(:subscription) { Factory.build(:subscription) }

  context "to a work" do
    before(:each) do
      subscription.subscribable = Factory.create(:work)
      subscription.save!
    end

    describe "when the work is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.should raise_error
      end
    end
  end

  context "to a series" do
    before(:each) do
      subscription.subscribable = Factory.create(:series)
      subscription.save!
    end

    describe "when the series is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.should raise_error
      end
    end
  end

  context "to a user" do
    before(:each) do
      subscription.subscribable = Factory.create(:user)
      subscription.save!
    end

    describe "when the user is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.should raise_error
      end
    end
  end

end
