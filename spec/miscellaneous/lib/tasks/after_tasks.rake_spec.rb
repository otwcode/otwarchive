require "spec_helper"

describe "rake After:reset_word_counts" do
  let(:en) { Language.find_by(short: "en") }
  let(:en_work) { create(:posted_work, language: en, chapter_attributes: { content: "Nice ride, Gloria!" }) }

  context "when there are multiple languages" do
    let(:es) { create(:language, short: "es") }
    let(:es_work) { create(:posted_work, language: es, chapter_attributes: { content: "Así pasa la gloria del mundo." }) }

    before do
      # Screw up the word counts
      en_work.update_column(:word_count, 3000)
      es_work.update_column(:word_count, 4000)
    end

    it "updates only works in the specified language" do
      subject.invoke("es")

      en_work.reload
      es_work.reload

      expect(en_work.word_count).to eq(3000)
      expect(es_work.word_count).to eq(6)
    end
  end

  context "when a work has multiple chapters" do
    let(:chapter) { create(:chapter, work: en_work, posted: true, position: 2, content: "A few more words never hurt.") }

    before do
      # Screw up the word counts
      chapter.update_column(:word_count, 9001)
      en_work.first_chapter.update_column(:word_count, 100_000)
      en_work.update_column(:word_count, 60)
    end

    it "updates word counts for each chapter and for the work" do
      subject.invoke("en")

      en_work.reload

      expect(en_work.word_count).to eq(9)
      expect(en_work.first_chapter.word_count).to eq(3)
      expect(en_work.last_chapter.word_count).to eq(6)
    end
  end
end

describe "rake After:unhide_invited_works" do
  let(:anonymous_collection) { create(:anonymous_collection) }
  let(:unrevealed_collection) { create(:unrevealed_collection) }
  let(:anonymous_unrevealed_collection) { create(:anonymous_unrevealed_collection) }
  let(:collection) { create(:collection) }

  let(:anonymous_work) { create(:posted_work, collections: [anonymous_collection]) }
  let(:unrevealed_work) { create(:posted_work, collections: [unrevealed_collection]) }
  let(:work) { create(:posted_work, collections: [collection]) }

  let(:invited_anonymous_work) { create(:posted_work, collections: [anonymous_collection]) }
  let(:invited_unrevealed_work) { create(:posted_work, collections: [unrevealed_collection]) }
  let(:invited_anonymous_unrevealed_work) { create(:posted_work, collections: [anonymous_unrevealed_collection]) }

  context "when invited works are incorrectly anonymous or unrevealed" do
    before do
      # Screw up collection items
      invited_anonymous_work.collection_items.first.update_columns(user_approval_status: CollectionItem::NEUTRAL)
      invited_unrevealed_work.collection_items.first.update_columns(user_approval_status: CollectionItem::NEUTRAL)
      invited_anonymous_unrevealed_work.collection_items.first.update_columns(user_approval_status: CollectionItem::NEUTRAL)
    end

    it "updates the anonymous and unrevealed status of invited works" do
      subject.invoke

      anonymous_work.reload
      unrevealed_work.reload
      work.reload
      invited_anonymous_work.reload
      invited_unrevealed_work.reload
      invited_anonymous_unrevealed_work.reload

      # Accepted works should be unchanged
      expect(anonymous_work.unrevealed?).to be(false)
      expect(anonymous_work.anonymous?).to be(true)
      expect(unrevealed_work.unrevealed?).to be(true)
      expect(unrevealed_work.anonymous?).to be(false)
      expect(work.unrevealed?).to be(false)
      expect(work.anonymous?).to be(false)

      # Invited works should no longer be anonymous or unrevealed
      expect(invited_anonymous_work.unrevealed?).to be(false)
      expect(invited_anonymous_work.anonymous?).to be(false)
      expect(invited_unrevealed_work.unrevealed?).to be(false)
      expect(invited_unrevealed_work.anonymous?).to be(false)
      expect(invited_anonymous_unrevealed_work.anonymous?).to be(false)
      expect(invited_anonymous_unrevealed_work.unrevealed?).to be(false)
    end
  end
end

describe "rake After:add_user_id_to_kudos" do
  context "when the kudos has no pseud_id" do
    it "doesn't add user_id if the kudos has an ip_address" do
      guest_kudos = create(:kudo, ip_address: "0.00.0.000")

      subject.invoke

      guest_kudos.reload
      expect(guest_kudos.user_id).to be(nil)  
    end

    it "doesn't add user_id if the kudos has no ip_address" do
      orphaned_kudos = create(:kudo)

      subject.invoke

      orphaned_kudos.reload
      expect(orphaned_kudos.user_id).to be(nil)  
    end
  end

  context "when the kudos has a pseud_id" do
    context "when the pseud exists" do
      it "doesn't add user_id if the user does not exist" do
        userless_pseud = create(:pseud)
        userless_kudos = create(:kudo, pseud_id: userless_pseud.id)
        userless_pseud.update_columns(user_id: 0)

        subject.invoke
  
        userless_kudos.reload
        expect(userless_kudos.user_id).to eq(nil)  
      end

      it "adds user_id if the user exists" do
        pseud = create(:pseud)
        user_kudos = create(:kudo, pseud_id: pseud.id)

        subject.invoke
  
        user_kudos.reload
        expect(user_kudos.user_id).to eq(pseud.user_id)  
      end
    end

    context "when the pseud doesn't exist" do
      it "doesn't add user_id" do
        pseudless_kudos = create(:kudo, pseud_id: 0)

        subject.invoke
  
        pseudless_kudos.reload
        expect(pseudless_kudos.user_id).to eq(nil)  
      end
    end
  end
end
