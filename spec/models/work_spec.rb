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
end
