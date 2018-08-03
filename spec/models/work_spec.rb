require 'spec_helper'

describe Work do
  # see lib/collectible_spec for collection-related tests

  it "creates a minimal work" do
    expect(create(:work)).to be_valid
  end

  context "when posted" do
    it "posts the first chapter" do
      work = create(:posted_work)
      work.first_chapter.posted.should == true
    end
  end

  context "create_stat_counter" do
    it "creates a stat counter for that work id" do
      expect {
        @work = build(:work)
        @work.save!
      }.to change{ StatCounter.all.count }.by(1)
      expect(StatCounter.where(work_id: @work.id)).to exist
    end
  end

  context "invalid title" do
    it { expect(build(:work, title: nil)).to be_invalid }

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "cannot be shorter than ArchiveConfig.TITLE_MIN" do
      expect(build(:work, title: Faker::Lorem.characters(too_short))).to be_invalid
    end

    let(:too_long) {ArchiveConfig.TITLE_MAX + 1}
    it "cannot be longer than ArchiveConfig.TITLE_MAX" do
      expect(build(:work, title: Faker::Lorem.characters(too_long))).to be_invalid
    end
  end

  context "clean_and_validate_title" do
    before do
      ArchiveConfig.TITLE_MIN = 10
    end
    it "strips out leading spaces from the title" do
      @work = create(:work, title: "    Has Leading Spaces")
      @work.reload
      expect(@work.title).to eq("Has Leading Spaces")
    end

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "errors if the title without leading spaces is shorter than #{ArchiveConfig.TITLE_MIN}" do
      expect {
        @work = create(:work, title: "     #{too_short}")
        @work.reload
      }.to raise_error(ActiveRecord::RecordInvalid,"Validation failed: Title must be at least #{ArchiveConfig.TITLE_MIN} characters long without leading spaces.")
    end

    # Reset the min characters in the title, so that the factory is valid
    after do
      ArchiveConfig.TITLE_MIN = 1
    end
  end

  context "invalid summary" do
    let(:too_long) {ArchiveConfig.SUMMARY_MAX + 1}
    it "cannot be longer than ArchiveConfig.SUMMARY_MAX" do
      expect(build(:work, title: Faker::Lorem.characters(too_long))).to be_invalid
    end
  end

  context "invalid notes" do
    let(:too_long) {ArchiveConfig.NOTES_MAX + 1}
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      expect(build(:work, title: Faker::Lorem.characters(too_long))).to be_invalid
    end
  end


  context "invalid endnotes" do
    let(:too_long) {ArchiveConfig.NOTES_MAX + 1}
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      expect(build(:work, title: Faker::Lorem.characters(too_long))).to be_invalid
    end
  end

  context "validate authors" do

    # TODO: testing specific invalid pseuds should take place in pseud_spec
    # However, we still want to make sure we can't save works without a valid pseud
    it "does not save an invalid pseud with *", :pending do
      @pseud = create(:pseud, name: "*pseud*")
      @work = Work.new(attributes_for(:work, authors: ["*pseud*"]))
      expect(@work.save).to be_falsey
      expect(@work.errors[:base]).to include["These pseuds are invalid: *pseud*"]
    end

    let(:invalid_work) { build(:no_authors) }
    it "does not save if author is blank" do
      expect(invalid_work.save).to be_falsey
      expect(invalid_work.errors[:base]).to include "Work must have at least one author."
    end
  end

  describe "#crossover" do
    it "is not crossover with one fandom" do
      fandom = create(:canonical_fandom, name: "nge")
      work = create(:work, fandoms: [fandom])
      expect(work.crossover).to be_falsy
    end

    it "is not crossover with one fandom and one of its synonyms" do
      rel = create(:canonical_fandom, name: "evanescence")
      syn = create(:fandom, name: "can't wake up (wake me up inside)", merger: rel)
      work = create(:work, fandoms: [rel, syn])
      expect(work.crossover).to be_falsy
    end

    it "is not crossover with multiple synonyms of one fandom" do
      rel = create(:canonical_fandom, name: "nge")
      syn1 = create(:fandom, name: "eva", merger: rel)
      syn2 = create(:fandom, name: "end of eva", merger: rel)
      work = create(:work, fandoms: [syn1, syn2])
      expect(work.crossover).to be_falsy
    end

    it "is not crossover with fandoms sharing a direct meta tag" do
      rel1 = create(:canonical_fandom, name: "rebuild")
      rel2 = create(:canonical_fandom, name: "campus apocalypse")
      meta_tag = create(:canonical_fandom, name: "nge")
      meta_tag.update_attribute(:sub_tag_string, "#{rel1.name},#{rel2.name}")
      rel1.reload
      rel2.reload

      work = create(:work, fandoms: [rel1, rel2])
      expect(work.crossover).to be_falsy
    end

    it "is not a crossover between fandoms sharing an indirect meta tag" do
      grand = create(:canonical_fandom)
      parent1 = create(:canonical_fandom)
      parent2 = create(:canonical_fandom)
      child1 = create(:canonical_fandom)
      child2 = create(:canonical_fandom)

      grand.update_attribute(:sub_tag_string, "#{parent1.name},#{parent2.name}")
      child1.update_attribute(:meta_tag_string, parent1.name)
      child2.update_attribute(:meta_tag_string, parent2.name)

      work = create(:work, fandom_string: "#{child1.name},#{child2.name}")
      expect(work.crossover).to be_falsey
    end

    it "is crossover with fandoms in different meta tag trees" do
      rel1 = create(:canonical_fandom, name: "rebuild again eventually")
      rel2 = create(:canonical_fandom, name: "evanescence")
      meta_tag = create(:canonical_fandom, name: "rebuild")
      meta_tag.update_attribute(:sub_tag_string, rel1.name)
      super_meta_tag = create(:canonical_fandom, name: "nge")
      super_meta_tag.update_attribute(:sub_tag_string, meta_tag.name)

      rel1.reload
      rel2.reload
      meta_tag.reload
      super_meta_tag.reload

      work = create(:work, fandoms: [rel1, rel2])
      expect(work.crossover).to be_truthy

      work = create(:work, fandoms: [meta_tag, super_meta_tag])
      expect(work.crossover).to be_falsy
    end

    it "is crossover with unrelated fandoms" do
      ships = [create(:canonical_fandom, name: "nge"), create(:canonical_fandom, name: "evanescence")]
      work = create(:work, fandoms: ships)
      expect(work.crossover).to be_truthy
    end

    it "is a crossover when missing meta-taggings" do
      f1 = create(:canonical_fandom)
      f2 = create(:canonical_fandom)
      f3 = create(:canonical_fandom)
      unrelated = create(:canonical_fandom)

      f2.update_attribute(:meta_tag_string, f3.name)
      f2.update_attribute(:sub_tag_string, f1.name)
      f1.meta_tags.delete(f3)

      work = create(:work, fandom_string: "#{f1.name}, #{unrelated.name}")
      expect(work.crossover).to be_truthy
    end

    context "when one tagged fandom has two unrelated meta tags" do
      let(:meta1) { create(:canonical_fandom) }
      let(:meta2) { create(:canonical_fandom) }
      let(:fandom) { create(:canonical_fandom) }

      before do
        fandom.update_attribute(:meta_tag_string, "#{meta1.name},#{meta2.name}")
      end

      it "is not a crossover with the fandom's synonym" do
        syn = create(:fandom, merger: fandom)
        work = create(:work, fandom_string: "#{fandom.name},#{syn.name}")
        expect(work.crossover).to be_falsey
      end

      it "is not a crossover with the fandom's meta tag" do
        work = create(:work, fandom_string: "#{fandom.name},#{meta1.name}")
        expect(work.crossover).to be_falsey
      end

      it "is not a crossover with another subtag of the fandom's meta tag" do
        sub = create(:canonical_fandom)
        sub.update_attribute(:meta_tag_string, meta1.name)
        work = create(:work, fandom_string: "#{fandom.name},#{sub.name}")
        expect(work.crossover).to be_falsey
      end

      it "is not a crossover with another fandom sharing the same two meta tags" do
        other = create(:canonical_fandom)
        other.update_attribute(:meta_tag_string, "#{meta1.name},#{meta2.name}")
        work = create(:work, fandom_string: "#{fandom.name},#{other.name}")
        expect(work.crossover).to be_falsey
      end

      it "is a crossover with another fandom sharing one meta tag, but with a second unrelated meta tag" do
        # The tag fandom and the tag other share one meta tag (meta2), but
        # fandom has a meta tag meta1 completely unrelated to other, and other
        # has a meta tag meta3 completely unrelated to fandom. So for the
        # purposes of this check, they count as unrelated, and thus a work
        # tagged with both is a crossover.
        meta3 = create(:canonical_fandom)
        other = create(:canonical_fandom)
        other.update_attribute(:meta_tag_string, "#{meta2.name},#{meta3.name}")
        work = create(:work, fandom_string: "#{fandom.name},#{other.name}")
        expect(work.crossover).to be_truthy
      end
    end
  end

  describe "#otp" do
    it "is not otp with no relationship" do
      work = create(:work)
      expect(work.relationships).to be_empty
      expect(work.otp).to be_falsy
    end

    it "is otp with only one relationship" do
      rel = create(:relationship, name: "asushin")
      work = create(:work, relationships: [rel])
      expect(work.otp).to be_truthy
    end

    it "is otp with one canonical relationship and one of its synonyms" do
      rel = create(:canonical_relationship, name: "kawoshin")
      syn = create(:relationship, name: "shinkawo", merger: rel)
      work = create(:work, relationships: [rel, syn])
      expect(work.otp).to be_truthy
    end

    it "is otp with multiple synonyms of the same canonical relationship" do
      rel = create(:canonical_relationship, name: "kawoshin")
      syn1 = create(:relationship, name: "shinkawo", merger: rel)
      syn2 = create(:relationship, name: "kaworu/shinji", merger: rel)
      work = create(:work, relationships: [syn1, syn2])
      expect(work.otp).to be_truthy
    end

    it "is not otp with unrelated relationships, one of which is canonical" do
      ships = [create(:relationship, name: "shinrei"), create(:canonical_relationship, name: "asurei")]
      work = create(:work, relationships: ships)
      expect(work.otp).to be_falsy
    end

    it "is not otp with unrelated relationships" do
      ships = [create(:relationship, name: "asushin"), create(:relationship, name: "asurei")]
      work = create(:work, relationships: ships)
      expect(work.otp).to be_falsy
    end

    it "is not otp with relationships sharing a meta tag" do
      rel1 = create(:canonical_relationship, name: "shinrei")
      rel2 = create(:canonical_relationship, name: "asurei")
      meta_tag = create(:canonical_relationship)
      meta_tag.update_attribute(:sub_tag_string, "#{rel1.name},#{rel2.name}")
      rel1.reload
      rel2.reload

      work = create(:work, relationships: [rel1, rel2])
      expect(work.otp).to be_falsy
    end
  end

  describe "#authors_to_sort_on" do
    let(:work) { build(:work) }

    context "when the pseuds start with special characters" do
      it "should remove those characters" do
        work.authors = [Pseud.new(name: "-jolyne")]
        expect(work.authors_to_sort_on).to eq "jolyne"

        work.authors = [Pseud.new(name: "_hermes")]
        expect(work.authors_to_sort_on).to eq "hermes"
      end
    end

    context "when the pseuds start with numbers" do
      it "should not remove numbers" do
        work.authors = [Pseud.new(name: "007james")]
        expect(work.authors_to_sort_on).to eq "007james"
      end
    end

    context "when the work is anonymous" do
      it "should set the author sorting to Anonymous" do
        work.in_anon_collection = true
        work.authors = [Pseud.new(name: "stealthy")]
        expect(work.authors_to_sort_on).to eq "Anonymous"
      end
    end

    context "when the work has multiple pseuds" do
      it "should combine them with commas" do
        work.authors = [Pseud.new(name: "diavolo"), Pseud.new(name: "doppio")]
        expect(work.authors_to_sort_on).to eq "diavolo,  doppio"
      end
    end
  end

  describe "work_skin_allowed" do
    context "public skin"

    context "private skin" do
      before :each do
        @skin_author = create(:user)
        @second_author = create(:user)
        @private_skin = create(:private_work_skin, author_id: @skin_author.id)
      end

      let(:work_author) {@skin_author}
      let(:work){build(:custom_work_skin, authors: [work_author.pseuds.first], work_skin_id: @private_skin.id)}
      it "can be used by the work skin author" do
        expect(work.save).to be_truthy
      end

      let(:work){build(:custom_work_skin, authors: [@second_author.pseuds.first], work_skin_id: @private_skin.id)}
      it "cannot be used by another user" do
        work.work_skin_allowed
        expect(work.errors[:base]).to include("You do not have permission to use that custom work stylesheet.")
      end
    end
  end

  describe "new recipients virtual attribute"  do

    before(:each) do
      @author = create(:user)
      @recipient1 = create(:user)
      @recipient2 = create(:user)
      @recipient3 = create(:user)

      @fandom1 = create(:fandom)
      @chapter1 = create(:chapter)

      @work = Work.new(title: "Title")
      @work.fandoms << @fandom1
      @work.authors = [@author.pseuds.first]
      @work.recipients = @recipient1.pseuds.first.name + "," + @recipient2.pseuds.first.name
      @work.chapters << @chapter1
    end

    it "should be the same as recipients when they are first added" do
      expect(@work.new_recipients).to eq(@work.recipients)
    end

    it "should only contain the new recipient if replacing the previous recipient" do
      @work.recipients = @recipient3.pseuds.first.name
      expect(@work.new_recipients).to eq(@recipient3.pseuds.first.name)
    end

    it "simple assignment should work" do
      @work.recipients = @recipient2.pseuds.first.name
      expect(@work.new_recipients).to eq(@recipient2.pseuds.first.name)
    end

    it "recipients should be unique" do
      @work.recipients = @recipient2.pseuds.first.name + "," + @recipient2.pseuds.first.name
      expect(@work.new_recipients).to eq(@recipient2.pseuds.first.name)
    end

  end

  describe "#find_by_url" do
    it "should find imported works with various URL formats" do
      [
        'http://foo.com/bar.html',
        'http://foo.com/bar',
        'http://lj-site.com/bar/foo?color=blue',
        'http://www.foo.com/bar'
      ].each do |url|
        work = create(:work, imported_from_url: url)
        expect(Work.find_by_url(url)).to eq(work)
        work.destroy
      end
    end

    it "should not mix up imported works with similar URLs or significant query parameters" do
      {
        'http://foo.com/12345' => 'http://foo.com/123',
        'http://efiction-site.com/viewstory.php?sid=123' => 'http://efiction-site.com/viewstory.php?sid=456',
        'http://www.foo.com/i-am-something' => 'http://foo.com/i-am-something/else'
      }.each do |import_url, find_url|
        work = create(:work, imported_from_url: import_url)
        expect(Work.find_by_url(find_url)).to_not eq(work)
        work.destroy
      end
    end

    it "should find works imported with irrelevant query parameters" do
      work = create(:work, imported_from_url: "http://lj-site.com/thing1?style=mine")
      expect(Work.find_by_url("http://lj-site.com/thing1?style=other")).to eq(work)
      work.destroy
    end

    it "gets the work from cache when searching for an imported work by URL" do
      url = "http://lj-site.com/thing2"
      work = create(:work, imported_from_url: url)
      expect(Rails.cache.read(Work.find_by_url_cache_key(url))).to be_nil
      expect(Work.find_by_url(url)).to eq(work)
      expect(Rails.cache.read(Work.find_by_url_cache_key(url))).to eq(work)
      work.destroy
    end
  end

  describe "#update_complete_status" do
    it "marks a work complete when it's been completed" do
      work = create(:posted_work, expected_number_of_chapters: 1)
      expect(work.complete).to be_truthy
    end

    it "marks a work incomplete when it's no longer completed" do
      work = create(:posted_work, expected_number_of_chapters: 1)
      work.update_attributes!(expected_number_of_chapters: nil)
      expect(work.reload.complete).to be_falsey
    end
  end

  describe "#hide_spam" do
    before do
      @admin_setting = AdminSetting.first || AdminSetting.create
      @work = create(:posted_work)
    end
    context "when the admin setting is enabled" do
      before do
        @admin_setting.update_attribute(:hide_spam, true)
      end
      it "automatically hides spam works and sends an email" do
        expect { @work.update_attributes!(spam: true) }.
          to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(@work.reload.hidden_by_admin).to be_truthy
        expect(ActionMailer::Base.deliveries.last.subject).to eq("[AO3] Your work was hidden as spam")
      end
    end
    context "when the admin setting is disabled" do
      before do
        @admin_setting.update_attribute(:hide_spam, false)
      end
      it "does not automatically hide spam works and does not send an email" do
        expect { @work.update_attributes!(spam: true) }.
          not_to change { ActionMailer::Base.deliveries.count }
        expect(@work.reload.hidden_by_admin).to be_falsey
      end
    end
  end
end
