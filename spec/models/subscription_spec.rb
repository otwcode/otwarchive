require 'spec_helper'

describe Subscription do
  let(:subscription) { build(:subscription) }

  context "to a work" do
    before do
      subscription.subscribable = create(:work)
      subscription.save!
    end

    describe "when the work is destroyed" do
      before do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context "to a series" do
    before do
      subscription.subscribable = create(:series)
      subscription.save!
    end

    describe "when the series is destroyed" do
      before do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context "to a user" do
    before do
      subscription.subscribable = create(:user)
      subscription.save!
    end

    describe "when the user is destroyed" do
      before do
        subscription.subscribable.destroy
      end

      it "should be destroyed" do
        expect { subscription.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context "when subscribable does not exist" do
    before do
      work = create(:work)
      subscription.subscribable_id = work.id
      subscription.subscribable_type = "Work"
      work.destroy
    end

    it "should be invalid" do
      expect(subscription.valid?).to be_falsey
    end
  end

  context "when subscribable is not a valid object to subscribe to" do
    before do
      subscription.subscribable_id = 1
      subscription.subscribable_type = "Pseud"
    end

    it "should be invalid" do
      expect(subscription.valid?).to be_falsey
    end
  end

  context "when subscribable_type is not a real model name" do
    before do
      subscription.subscribable_id = 1
      subscription.subscribable_type = "Серия"
    end

    it "should be invalid" do
      expect(subscription.valid?).to be_falsey
    end
  end

  describe "#valid_notification_entry?" do
    let(:subscription) { build(:subscription) }
    let(:series) { build(:series) }
    let(:work) { build(:work) }
    let(:chapter) { build(:chapter) }
    let(:anon_work) { build(:work, collections: [build(:anonymous_collection)]) }
    let(:anon_series) { build(:series, works: [anon_work]) }
    let(:anon_chapter) { build(:chapter, work: anon_work) }

    it "returns false when creation is not a work or chapter" do
      expect(subscription.valid_notification_entry?(series)).to be_falsey
    end

    context "when subscribable is a series" do
      context "when series is not anonymous" do
        let(:subscription) { build(:subscription, subscribable: series) }

        it "returns true for a non-anonymous work" do
          expect(subscription.valid_notification_entry?(work)).to be_truthy
        end

        it "returns true for a non-anonymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_truthy
        end

        it "returns false for an anonymous work" do
          expect(subscription.valid_notification_entry?(anon_work)).to be_falsey
        end

        it "returns false for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_falsey
        end
      end

      context "when series is anonymous" do
        let(:subscription) { build(:subscription, subscribable: anon_series) }

        it "returns false for a non-anonymous work" do
          expect(subscription.valid_notification_entry?(work)).to be_falsey
        end

        it "returns false for a non-anoymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_falsey
        end

        it "returns true for an anonymous work" do
          expect(subscription.valid_notification_entry?(anon_work)).to be_truthy
        end

        it "returns true for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_truthy
        end
      end
    end

    context "when subscribable is a user" do
      let(:subscription) { build(:subscription, subscribable: create(:user)) }

      it "returns true for a non-anonymous work" do
        expect(subscription.valid_notification_entry?(work)).to be_truthy
      end

      it "returns true for a non-anonymous chapter" do
        expect(subscription.valid_notification_entry?(chapter)).to be_truthy
      end

      it "returns false for an anonymous work" do
        expect(subscription.valid_notification_entry?(anon_work)).to be_falsey
      end

      it "returns false for an anonymous chapter" do
        expect(subscription.valid_notification_entry?(anon_chapter)).to be_falsey
      end
    end

    context "when subscribable is a work" do
      context "when work is not anonymous" do
        let(:subscription) { build(:subscription, subscribable: work) }

        it "returns true for a non-anonymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_truthy
        end

        it "returns false for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_falsey
        end
      end

      context "when work is anonymous" do
        let(:subscription) { build(:subscription, subscribable: anon_work) }

        it "returns false for a non-anonymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_falsey
        end

        it "returns true for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_truthy
        end
      end
    end
  end
end
