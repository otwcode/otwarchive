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
  context "when user has no pseud" do
    it "runs without erroring or updating user_id or pseud_id" do
      pseudless_user = create(:user)
      deleted_pseud_id = pseudless_user.default_pseud_id
      deleted_pseud_kudos = create(:kudo,
                                   pseud_id: deleted_pseud_id)

      pseudless_user.default_pseud.delete
      pseudless_user.reload
      deleted_pseud_kudos.reload

      subject.invoke

      deleted_pseud_kudos.reload
      expect(deleted_pseud_kudos.user_id).to be(nil)
      expect(deleted_pseud_kudos.pseud_id).to eq(deleted_pseud_id)      
    end
  end

  context "when user has a pseud" do
    # If the user has left kudos on a work and is later added to it as a
    # co-creator, the kudos will be invalid due to the is_author? validation.
    # The kudos should still update because update_all skips validations.
    context "when kudos is invalid" do
      it "adds user_id and doesn't update pseud_id" do
        co_creator = create(:user)
        work = create(:work)
        co_creator_kudos = create(:kudo,
                                  commentable: work,
                                  pseud_id: co_creator.default_pseud_id)

        # Add user to work.
        work.creatorships.create(pseud: co_creator.default_pseud)
        work.reload

        subject.invoke

        co_creator_kudos.reload
        expect(co_creator_kudos.user_id).to eq(co_creator.id)
        expect(co_creator_kudos.pseud_id).to eq(co_creator.default_pseud_id)
      end
    end

    context "when kudos is valid" do
      it "adds user_id and doesn't update pseud_id" do
        user = create(:user)
        user_kudos = create(:kudo, pseud_id: user.default_pseud_id)

        subject.invoke

        user_kudos.reload
        expect(user_kudos.user_id).to eq(user.id)
        expect(user_kudos.pseud_id).to eq(user.default_pseud_id)
      end
    end
  end

  context "when the user has multiple pseuds" do
    it "updates user_id for all pseuds' kudos" do
      user_with_pseuds = create(:user)
      second_pseud = create(:pseud, user_id: user_with_pseuds.id)
      default_pseud_kudos = create(:kudo,
                                   pseud_id: user_with_pseuds.default_pseud_id)
      second_pseud_kudos = create(:kudo, pseud_id: second_pseud.id)

      subject.invoke

      default_pseud_kudos.reload
      expect(default_pseud_kudos.user_id).to eq(user_with_pseuds.id)
      expect(default_pseud_kudos.pseud_id).to eq(user_with_pseuds.default_pseud_id)

      second_pseud_kudos.reload
      expect(second_pseud_kudos.user_id).to eq(user_with_pseuds.id)
      expect(second_pseud_kudos.pseud_id).to eq(second_pseud.id)
    end
  end
end

describe "rake After:update_indexed_stat_counter_kudo_count", work_search: true do
  let(:work) { create(:posted_work) }
  let(:stat_counter) { work.stat_counter }
  let!(:kudo_bundle) { create_list(:kudo, 2, commentable_id: work.id) }

  before do
    stat_counter.update_column(:kudos_count, 3)
    run_all_indexing_jobs
  end

  it "updates kudos_count" do
    expect(stat_counter.kudos_count).to eq(3)

    subject.invoke

    stat_counter.reload
    expect(stat_counter.kudos_count).to eq(work.kudos.count)
  end

  it "updates work index" do
    expect do
      subject.invoke
      run_all_indexing_jobs
    end.to change { WorkSearchForm.new(kudos_count: work.kudos.count.to_s)
                      .search_results.size }.from(0).to(1)
  end
end

