require 'spec_helper'

describe Subscription do
  let(:subscription) { FactoryGirl.build(:subscription) }

  context "to a work" do
    before(:each) do
      subscription.subscribable = FactoryGirl.create(:work)
      subscription.save!
    end

    describe "when the work is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error
      end
    end
  end

  context "to a series" do
    before(:each) do
      subscription.subscribable = FactoryGirl.create(:series)
      subscription.save!
    end

    describe "when the series is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error
      end
    end
  end

  context "to a user" do
    before(:each) do
      subscription.subscribable = FactoryGirl.create(:user)
      subscription.save!
    end

    describe "when the user is destroyed" do
      before(:each) do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error
      end
    end
  end

end
