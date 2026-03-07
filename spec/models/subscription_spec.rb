require 'spec_helper'

describe Subscription do
  let(:subscription) { build(:subscription) }
  let(:work) { create(:work) }
  let(:series) { create(:series) }
  let(:user) { create(:user) }

  describe "de-duplicating subscriptions" do
    let(:author) { create(:user) }
    let(:author2) { create(:user) }
    let(:subscriber) { create(:user) }

    let(:work) { create(:work, authors: [author.default_pseud, author2.default_pseud]) }
    let(:series) { create(:series, works: [work]) }

    context "#for_work_with_duplicates"
      it "picks at most one subscription of each type" do
        create(:subscription, user: subscriber, subscribable: author)
        create(:subscription, user: subscriber, subscribable: author2)
        create(:subscription, user: subscriber, subscribable: work)
        create(:subscription, user: subscriber, subscribable: series)
        series2 = create(:series, works: [work])
        create(:subscription, user: subscriber, subscribable: series2)
        expect(Subscription.for_work_with_duplicates(work).map(&:subscribable_type)).to contain_exactly("Work", "Series", "User")
      end
    end

    context "#for_work" do
      it "picks only a user's work-type subscription when a user has multiple relevant subscriptions" do
        create(:subscription, user: subscriber, subscribable: author)
        work_subscription = create(:subscription, user: subscriber, subscribable: work)
        create(:subscription, user: subscriber, subscribable: series)
        expect(Subscription.for_work(work)).to contain_exactly(work_subscription)
      end

      it "picks one subscription per subscriber" do
        user1_author_subscription = create(:subscription, user: subscriber, subscribable: author)
        user2_work_subscription = create(:subscription, user: create(:user), subscribable: work)
        expect(Subscription.for_work(work)).to contain_exactly(user1_author_subscription, user2_work_subscription)
      end
    end

    context "#pick_most_relevant_of" do
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
      subscription.subscribable = work
      subscription.save!
    end

    it "has a name" do
      expect(subscription.name).to eq(work.title)
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
      subscription.subscribable = series
      subscription.save!
    end

    it "has a name" do
      expect(subscription.name).to eq(series.title)
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
      subscription.subscribable = user
      subscription.save!
    end

    it "has a name" do
      expect(subscription.name).to eq(user.login)
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

    it "has a name" do
      expect(subscription.name).to eq("Deleted item")
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
    let(:draft) { build(:draft) }
    let(:chapter) { build(:chapter) }
    let(:anon_work) { build(:work, collections: [build(:anonymous_collection)]) }
    let(:anon_series) { build(:series, works: [anon_work]) }
    let(:anon_chapter) { build(:chapter, work: anon_work) }
    let(:orphan_pseud) { create(:user, login: "orphan_account").default_pseud }

    it "returns false when the creation is nil" do
      expect(subscription.valid_notification_entry?(nil)).to be_falsey
    end

    it "returns false when the creation is not a work or chapter" do
      expect(subscription.valid_notification_entry?(series)).to be_falsey
    end

    context "when the creation is a work" do
      it "returns false when the creation is unposted" do
        expect(subscription.valid_notification_entry?(draft)).to be_falsey
      end

      # TODO: AO3-3620 & AO3-5696: Allow subscriptions to orphan_account to receive notifications
      it "returns false when the creation is by orphan_account" do
        expect(subscription.valid_notification_entry?(create(:work, authors: [orphan_pseud]))).to be_falsey
      end

      it "returns false when the creation is hidden_by_admin" do
        expect(subscription.valid_notification_entry?(build(:work, hidden_by_admin: true))).to be_falsey
      end
    end

    context "when the creation is a chapter" do
      it "returns false when the creation is unposted" do
        expect(subscription.valid_notification_entry?(build(:chapter, :draft))).to be_falsey
      end

      it "returns false when the chapter is on an unposted work" do
        expect(subscription.valid_notification_entry?(build(:chapter, work: draft))).to be_falsey
      end

      # TODO: AO3-3620 & AO3-5696: Allow subscriptions to orphan_account to receive notifications
      it "returns false when the creation is by orphan_account" do
        expect(subscription.valid_notification_entry?(create(:chapter, authors: [orphan_pseud]))).to be_falsey
      end

      it "returns false when the chapter is on a hidden work" do
        expect(subscription.valid_notification_entry?(build(:chapter, work: build(:work, hidden_by_admin: true)))).to be_falsey
      end
    end

    # TODO: AO3-1250: Anon series subscription improvements
    context "when subscribable is a series" do
      context "when series is not anonymous" do
        let(:subscription) { build(:subscription, subscribable: series) }

        it "returns true for a non-anonymous work" do
          expect(subscription.valid_notification_entry?(work)).to be_truthy
        end

        it "returns true for a non-anonymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_truthy
        end

        it "returns true for an anonymous work" do
          expect(subscription.valid_notification_entry?(anon_work)).to be_truthy
        end

        it "returns true for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_truthy
        end
      end

      context "when series is anonymous" do
        let(:subscription) { build(:subscription, subscribable: anon_series) }

        it "returns true for a non-anonymous work" do
          expect(subscription.valid_notification_entry?(work)).to be_truthy
        end

        it "returns true for a non-anoymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_truthy
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

        # an non-anon work can only have non-anon chapters
        it "returns true for a non-anonymous chapter" do
          expect(subscription.valid_notification_entry?(chapter)).to be_truthy
        end
      end

      context "when work is anonymous" do
        let(:subscription) { build(:subscription, subscribable: anon_work) }

        # an anon work can only have anon chapters
        it "returns true for an anonymous chapter" do
          expect(subscription.valid_notification_entry?(anon_chapter)).to be_truthy
        end
      end
    end
  end

  it "can have an id larger than unsigned int" do
    subscription = build(:subscription, id: 5_294_967_295, subscribable: work)

    expect(subscription).to be_valid
    expect(subscription.save).to be_truthy
    expect(subscription.name).to eq(work.title)
  end
end
