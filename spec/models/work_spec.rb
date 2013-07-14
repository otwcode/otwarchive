require 'spec_helper'

describe Work do
  # see lib/collectible_spec for collectio n-related tests

  it "creates a minimally work" do
    create(:work).should be_valid
  end

  context "work skin" do
    it "work_skin_allowed true"
    it "work_skin_allowed false"
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

    it "is too short after leading " do
      pending "Changing the ArchiveConfig.TITLE_MIN" do
        build(:work, title: " #{too_short}").should be_invalid
      end
    end
  end

  it "strips out leading spaces from the title" do
    @work = create(:work, title: "    Has Leading Spaces")
    @work.reload
    @work.title.should == "Has Leading Spaces"
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

    it "does not save an invalid pseud with *" do
      @work = build(:work, author: ["*pseud*"])
      @work.should be_invalid
    end

    it "does not save if author is blank" do
      @work = build(:no_authors)
      @work.should be_invalid
    end
  end

  it "should send an email when added to collection"

  describe "new recipients virtual attribute", :pending do

    before(:each) do
      @author = FactoryGirl.create(:user)
      @recipient1 = FactoryGirl.create(:user)
      @recipient2 = FactoryGirl.create(:user)
      @recipient3 = FactoryGirl.create(:user)

      @fandom1 = FactoryGirl.create(:fandom)
      @chapter1 = FactoryGirl.create(:chapter)

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
