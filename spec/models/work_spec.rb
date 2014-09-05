require 'spec_helper'

describe Work do
  # see lib/collectible_spec for collectio n-related tests

  it "creates a minimally work" do
    create(:work).should be_valid
  end

  context "create_stat_counter" do
    it "creates a stat counter for that work id" do
      expect {
        @work = build(:work)
        @work.save!
      }.to change{ StatCounter.all.count }.by(1)
      StatCounter.where(:work_id => @work.id).should exist
    end
  end

  context "invalid title" do
    it { build(:work, title: nil).should be_invalid }

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "cannot be shorter than ArchiveConfig.TITLE_MIN" do
      build(:work, title: Faker::Lorem.characters(too_short)).should be_invalid
    end

    let(:too_long) {ArchiveConfig.TITLE_MAX + 1}
    it "cannot be longer than ArchiveConfig.TITLE_MAX" do
      build(:work, title: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "clean_and_validate_title" do
    before do
      ArchiveConfig.TITLE_MIN = 10
    end
    it "strips out leading spaces from the title" do
      @work = create(:work, title: "    Has Leading Spaces")
      @work.reload
      @work.title.should == "Has Leading Spaces"
    end

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "errors if the title without leading spaces is shorter than #{ArchiveConfig.TITLE_MIN}" do
      expect { create(:work, title: "     #{too_short}")}.to raise_error(ActiveRecord::RecordInvalid,"Validation failed: Title must be at least #{ArchiveConfig.TITLE_MIN} characters long without leading spaces.")
    end

    # Reset the min characters in the title, so that the factory is valid
    after do
      ArchiveConfig.TITLE_MIN = 1
    end
  end

  context "invalid summary" do
    let(:too_long) {ArchiveConfig.SUMMARY_MAX + 1}
    it "cannot be longer than ArchiveConfig.SUMMARY_MAX" do
      build(:work, title: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "invalid notes" do
    let(:too_long) {ArchiveConfig.NOTES_MAX + 1}
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      build(:work, title: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end


  context "invalid endnotes" do
    let(:too_long) {ArchiveConfig.NOTES_MAX + 1}
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      build(:work, title: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "validate authors" do

    # TODO: testing specific invalid pseuds should take place in pseud_spec
    # However, we still want to make sure we can't save works without a valid pseud
    it "does not save an invalid pseud with *", :pending do
      @pseud = create(:pseud, name: "*pseud*")
      @work = Work.new(attributes_for(:work, authors: ["*pseud*"]))
      @work.save.should be_false
      @work.errors[:base].should include["These pseuds are invalid: *pseud*"]
    end

    let(:invalid_work) { build(:no_authors) }
    it "does not save if author is blank" do
      invalid_work.save.should be_false
      invalid_work.errors[:base].should include "Work must have at least one author."
    end
  end

  describe "work_skin_allowed", :pending do
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
        puts work_author.login
        puts work_author.pseuds.first.name
        work.save.should be_true
      end

      let(:work){build(:custom_work_skin, authors: [@second_author.pseuds.first], work_skin_id: @private_skin.id)}
      it "cannot be used by another user" do
        puts @skin_author.login
        puts @skin_author.pseuds.first.name
        puts @second_author.login
        puts @second_author.pseuds.first.name
        work.save.should be_false
         work.errors[:base].should include("You do not have permission to use that custom work stylesheet.")
      end
    end
  end

  #TODO: Move to a collection mailer spec
  it "should send an email when added to collection"

  describe "new recipients virtual attribute", :pending do

    before(:each) do
      @author = create(:user)
      @recipient1 = create(:user)
      @recipient2 = create(:user)
      @recipient3 = create(:user)

      @fandom1 = create(:fandom)
      @chapter1 = create(:chapter)

      @work = Work.new(:title => "Title")
      @work.fandoms << @fandom1
      @work.authors = [@author.pseuds.first]
      @work.recipients = @recipient1.pseuds.first.name + "," + @recipient2.pseuds.first.name
      @work.chapters << @chapter1
    end

    it "should be the same as recipients when they are first added" do
      @work.new_recipients.should eq(@work.recipients)
    end

    it "should only contain the new recipients when more are added" do
      @work.recipients += "," + @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end

    it "should only contain the new recipient if replacing the previous recipient" do
      @work.recipients = @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end

    it "should be empty if one or more of the original recipients are removed" do
      @work.recipients = @recipient2.pseuds.first.name
      @work.new_recipients.should be_empty
    end

  end

    
end
