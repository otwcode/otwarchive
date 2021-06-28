require "spec_helper"

describe "rake After:reset_word_counts" do
  let(:en) { Language.find_by(short: "en") }
  let(:en_work) { create(:work, language: en, chapter_attributes: { content: "Nice ride, Gloria!" }) }

  context "when there are multiple languages" do
    let(:es) { create(:language, short: "es") }
    let(:es_work) { create(:work, language: es, chapter_attributes: { content: "Así pasa la gloria del mundo." }) }

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

  let(:anonymous_work) { create(:work, collections: [anonymous_collection]) }
  let(:unrevealed_work) { create(:work, collections: [unrevealed_collection]) }
  let(:work) { create(:work, collections: [collection]) }

  let(:invited_anonymous_work) { create(:work, collections: [anonymous_collection]) }
  let(:invited_unrevealed_work) { create(:work, collections: [unrevealed_collection]) }
  let(:invited_anonymous_unrevealed_work) { create(:work, collections: [anonymous_unrevealed_collection]) }

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

describe "rake After:update_indexed_stat_counter_kudo_count", work_search: true do
  let(:work) { create(:work) }
  let(:stat_counter) { work.stat_counter }
  let!(:kudo_bundle) { create_list(:kudo, 2, commentable_id: work.id) }

  before do
    stat_counter.update_column(:kudos_count, 3)
    run_all_indexing_jobs
  end

  it "updates kudos_count on StatCounter" do
    expect do
      subject.invoke
    end.to change {
      stat_counter.reload.kudos_count
    }.from(3).to(work.kudos.count)
  end

  it "updates kudos_count in work index" do
    expect do
      subject.invoke
      run_all_indexing_jobs
    end.to change {
      WorkSearchForm.new(kudos_count: work.kudos.count.to_s).search_results.size
    }.from(0).to(1)
  end
end

describe "rake After:replace_dewplayer_embeds" do
  let!(:dewplayer_work) { create(:work, chapter_attributes: { content: '<embed type="application/x-shockwave-flash" flashvars="mp3=https://example.com/HINOTORI.mp3" src="https://archiveofourown.org/system/dewplayer/dewplayer-vol.swf" width="250" height="27"></embed>' }) }
  let!(:embed_work) { create(:work, chapter_attributes: { content: '<embed type="application/x-shockwave-flash" flashvars="audioUrl=https://example.com/失礼しますが、RIP♡-Explicit.mp3" src="http://podfic.com/player/audio-player.swf" width="400" height="27"></embed>' }) }

  it "converts only works using Dewplayer embeds" do
    expect do
      subject.invoke
    end.to avoid_changing { embed_work.reload.first_chapter.content }
      .and output("Converted 1 chapter(s).\n").to_stdout

    expect(dewplayer_work.reload.first_chapter.content).to include('<audio src="https://example.com/HINOTORI.mp3" controls="controls" crossorigin="anonymous" preload="metadata"></audio>')
  end

  it "outputs chapter IDs with Dewplayer embeds that couldn't be converted due to bad flashvars format" do
    dewplayer_work.first_chapter.update_column(:content, '<embed type="application/x-shockwave-flash" flashvars="https://example.com/HINOTORI.mp3" src="https://archiveofourown.org/system/dewplayer/dewplayer-vol.swf" width="250" height="27"></embed>')
    expect do
      subject.invoke
    end.to output("Couldn't convert 1 chapter(s): #{dewplayer_work.first_chapter.id}\nConverted 0 chapter(s).\n").to_stdout
  end

  it "outputs chapter IDs with Dewplayer embeds that raise exceptions" do
    allow_any_instance_of(Chapter).to receive(:update_attribute).and_raise("monkey wrench")
    expect do
      subject.invoke
    end.to output("Couldn't convert 1 chapter(s): #{dewplayer_work.first_chapter.id}\nConverted 0 chapter(s).\n").to_stdout
  end
end

describe "rake After:fix_teen_and_up_imported_rating" do
  let!(:noncanonical_teen_rating) do 
    tag = Rating.create(name: "Teen & Up Audiences")
    tag.canonical = false
    tag.save!(validate: false)
    return tag
  end
  let!(:canonical_gen_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_GENERAL_TAG_NAME, canonical: true) }
  let!(:canonical_teen_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME, canonical: true) }
  let!(:work_with_noncanonical_rating) { create(:work, rating_string: noncanonical_teen_rating.name) }
  let!(:work_with_canonical_and_noncanonical_ratings) { create(:work, rating_string: [noncanonical_teen_rating.name, ArchiveConfig.RATING_GENERAL_TAG_NAME].join(",")) }

  it "updates the works' ratings to the canonical teen rating" do
    subject.invoke
    expect(work_with_noncanonical_rating.reload.ratings.to_a).to contain_exactly(canonical_teen_rating)
    expect(work_with_canonical_and_noncanonical_ratings.reload.ratings.to_a).to contain_exactly(canonical_teen_rating, canonical_gen_rating)
  end
end

describe "rake After:clean_up_noncanonical_categories" do
  let!(:canonical_category_tag) { Category.find_or_create_by(name: ArchiveConfig.CATEGORY_GEN_TAG_NAME, canonical: true) }
  let!(:noncanonical_category_tag) do
    tag = Category.create(name: "Borked category tag")
    tag.canonical = false
    tag.save!(validate: false)
    return tag
  end
  let!(:work_with_noncanonical_categ) do 
    work = create(:work)
    work.categories = [noncanonical_category_tag]
    work.save!(validate: false)
    return work
  end
  let!(:work_with_canonical_and_noncanonical_categs) do
    work = create(:work)
    work.categories = [noncanonical_category_tag, canonical_category_tag]
    work.save!(validate: false)
    return work
  end

  it "changes and replaces the noncanonical category tags" do
    subject.invoke
    work_with_noncanonical_categ.reload
    work_with_canonical_and_noncanonical_categs.reload

    # Changes the noncanonical categories into freeforms
    noncanonical_category_tag = Tag.find_by(name: "Borked category tag")
    expect(noncanonical_category_tag).to be_a(Freeform)
    expect(work_with_noncanonical_categ.freeforms.to_a).to include(noncanonical_category_tag)
    expect(work_with_canonical_and_noncanonical_categs.freeforms.to_a).to include(noncanonical_category_tag)

    # Leaves the works that had no other categories without a category
    expect(work_with_noncanonical_categ.categories.to_a).to be_empty

    # Leaves the works that had other categories with those categories
    expect(work_with_canonical_and_noncanonical_categs.categories.to_a).to contain_exactly(canonical_category_tag)
  end
end

describe "rake After:fix_tags_with_extra_spaces" do
  let(:borked_tag) { Freeform.create(name: "whatever") }

  it "replaces the spaces with the same number of underscores" do
    borked_tag.update_column(:name, "\u00A0\u2002\u2003\u202F\u205FBorked\u00A0\u2002\u2003\u202Ftag\u00A0\u2002\u2003\u202F\u205F")
    subject.invoke

    borked_tag.reload
    expect(borked_tag.name).to eql("_____Borked____tag_____")
  end

  it "handles duplicated names" do
    Freeform.create(name: "Borked_tag")
    borked_tag.update_column(:name, "Borked\u00A0tag")
    subject.invoke

    borked_tag.reload
    expect(borked_tag.name).to eql("Borked_tag_")
  end

  it "handles tags with quotes" do
    borked_tag.update_column(:name, "\u00A0\"'quotes'\"")
    expect do
      subject.invoke
    end.to output(/.*Tag ID,Old tag name,New tag name\n#{borked_tag.id},\"\u00A0\"\"'quotes'\"\"\",\"_\"\"'quotes'\"\"\"\n$/).to_stdout

    borked_tag.reload
    expect(borked_tag.name).to eql("_\"'quotes'\"")
  end
end
