require 'spec_helper'

describe Subscription do
  let(:subscription) { build(:subscription) }

  describe "a creation's" do
    let(:author) { create(:user) }
    let(:subscriber) { create(:user) }

    let(:work) { create(:work, authors: [author.default_pseud]) }
    let(:series) { create(:series, works: [work]) }

    context "subscriptions with duplicates" do
      it "picks at most one subscription of each type" do
        create(:subscription, user: subscriber, subscribable: author)
        create(:subscription, user: subscriber, subscribable: work)
        create(:subscription, user: subscriber, subscribable: series)
        series2 = create(:series, works: [work])
        create(:subscription, user: subscriber, subscribable: series2)
        expect(Subscription.for_work_with_duplicates(work).map { |s| s.subscribable_type }).to contain_exactly("Work", "Series", "User")
      end
    end

    context "subscriptions to notify" do
      it "picks only a user's work-type subscription when a user has multiple relevant subscriptions" do
        author_subscription = create(:subscription, user: subscriber, subscribable: author)
        work_subscription = create(:subscription, user: subscriber, subscribable: work)
        series_subscription = create(:subscription, user: subscriber, subscribable: series)
        expect(Subscription.for_work(work)).to contain_exactly(work_subscription)
      end

      it "picks one subscription per subscriber" do
        user1_author_subscription = create(:subscription, user: subscriber, subscribable: author)
        user2_work_subscription = create(:subscription, user: create(:user), subscribable: work)
        expect(Subscription.for_work(work)).to contain_exactly(user1_author_subscription, user2_work_subscription)
      end
    end

    context "subscription preference order" do
      let!(:work_subscription) { create(:subscription, user: subscriber, subscribable: work) }
      let!(:series_subscription) { create(:subscription, user: subscriber, subscribable: series) }
      let!(:author_subscription) { create(:subscription, user: subscriber, subscribable: author) }

      it "picks a user subscription when it's the only one" do
        expect(Subscription.pick_most_relevant_of([author_subscription])).to be(author_subscription)
      end

      it "prefers a work subscription over a series subscription" do
        expect(Subscription.pick_most_relevant_of([series_subscription, work_subscription])).to be(work_subscription)
      end

      it "prefers a work subscription over a user subscription" do
        expect(Subscription.pick_most_relevant_of([work_subscription, author_subscription])).to be(work_subscription)
      end

      it "prefers a series subscription over a user subscription" do
        expect(Subscription.pick_most_relevant_of([series_subscription, author_subscription])).to be(series_subscription)
      end

      it "prefers a work subscription over a series and user subscription" do
        expect(Subscription.pick_most_relevant_of([author_subscription, series_subscription, work_subscription])).to be(work_subscription)
      end
    end
  end

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
end
