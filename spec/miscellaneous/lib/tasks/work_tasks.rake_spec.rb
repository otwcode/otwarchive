require 'spec_helper'

describe "rake work:purge_old_drafts" do
  context "when the draft is 27 days old" do
    it "doesn't delete the draft" do
      draft = Delorean.time_travel_to 27.days.ago do
        create(:draft)
      end

      subject.invoke

      expect { draft.reload }.not_to \
        raise_exception
    end
  end

  context "when there is a posted work that is 32 days old" do
    it "doesn't delete the work" do
      work = Delorean.time_travel_to 32.days.ago do
        create(:posted_work)
      end

      subject.invoke

      expect { work.reload }.not_to \
        raise_exception
    end
  end

  context "when the draft has multiple chapters" do
    it "deletes the draft" do
      draft = Delorean.time_travel_to 32.days.ago do
        create(:draft)
      end

      create(:chapter, work: draft, authors: draft.pseuds, position: 2)
      create(:chapter, work: draft, authors: draft.pseuds, position: 3)
      expect(draft.chapters.count).to eq(3)

      subject.invoke

      expect { draft.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  context "when the draft is in a collection" do
    let(:collection) { create(:collection) }

    it "deletes the draft" do
      draft = Delorean.time_travel_to 32.days.ago do
        create(:draft, collections: [collection])
      end

      subject.invoke

      expect { draft.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  context "when the draft is the last work in a series" do
    let(:series) { create(:series) }

    it "deletes the draft" do
      draft = Delorean.time_travel_to 32.days.ago do
        create(:draft, series: [series])
      end

      subject.invoke

      expect { draft.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
      expect { series.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  context "when one of the drafts cannot be deleted" do
    let(:collection) { create(:collection) }

    it "deletes the other drafts and prints an error" do
      draft1 = Delorean.time_travel_to 34.days.ago do
        create(:draft)
      end

      draft2 = Delorean.time_travel_to 33.days.ago do
        create(:draft, collections: [collection])
      end

      draft3 = Delorean.time_travel_to 32.days.ago do
        create(:draft)
      end

      # Make the deletion of draft 2 fail.
      allow_any_instance_of(CollectionItem).to \
        receive(:destroy).and_raise("deletion failed!")

      subject.invoke

      expect { draft1.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
      expect { draft2.reload }.not_to \
        raise_exception
      expect { draft3.reload }.to \
        raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
