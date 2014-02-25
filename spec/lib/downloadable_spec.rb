# encoding: utf-8
require 'spec_helper'

describe Downloadable do
         
  before(:each) do 
    @author = User.find_by_login("someone") ||
      FactoryGirl.create(:user, login: "someone", email: "someone@somewhere.com")
  end

  describe "#download_title" do

    it "will usually be the same as the title" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: "Safe Title")
      expect(work.download_title).to eq(work.title)
    end
    
    it "will have html entities stripped completely" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: "&lt;This &amp; That&gt;")
      expect(work.download_title).to eq("This That")
    end
    
    it "will have special characters stripped" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: "Not! Safe../    Title?@!#\\'*&^$`\"")
      expect(work.download_title).to eq("Not Safe Title")
    end
    
    it "will transliterate non-ascii characters when possible" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: "♥ é Türkçe başlıkta")
      expect(work.download_title).to eq("e Turkce baslikta")
    end
    
    it "will use the work id if too much is stripped" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: "流亡在阿尔比恩")
      expect(work.download_title).to eq("Work #{work.id}")
    end
    
    it "will be truncated if longer than 24 characters" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first], title: (1..ArchiveConfig.TITLE_MAX).map { (65 + rand(26)).chr }.join)
      expect(work.download_title.length).to be <= 24
      expect(work.download_title).to eq(work.title.truncate(24, :separator => ' ', :omission => '')) 
    end
    
  end

  describe "#download_authors" do
    it "will usually be the same as the author" do
      work = FactoryGirl.create(:work, authors: [@author.pseuds.first])
      expect(work.download_authors).to eq(@author.pseuds.first.name)
    end
    
    it "will transliterate non-ascii characters when possible" do
      pseud2 = FactoryGirl.create(:pseud, user: @author, name: "Türkçe")
      work = FactoryGirl.create(:work, authors: [pseud2])
      expect(work.download_authors).to eq("Turkce")      
    end
    
    it "will use login if the ascii-converted pseud is too short" do
      pseud2 = FactoryGirl.create(:pseud, user: @author, name: "Фиолетовая Лиса")
      work = FactoryGirl.create(:work, authors: [pseud2])
      expect(work.download_authors).to eq(@author.login)
    end
  end

  describe "the download files" do
    before(:each) do
      @work = FactoryGirl.create(:work, authors: [@author.pseuds.first])
      FileUtils.mkdir_p @work.download_dir
      @filename = @work.download_basename + ".mobi"
      FileUtils.touch(@filename)
    end

    describe "#download_dir" do
      it "will be createable" do
        expect(File.exists?(@work.download_dir)).to be_true
      end

      it "will be cleaned up when object is changed" do
        @work.title = "New Title"
        @work.save
        expect(File.exists?(@work.download_dir)).to be_false
      end
      
      it "will be cleaned up when object is destroyed" do
        @work.destroy
        expect(File.exists?(@work.download_dir)).to be_false
      end
    end
    
    describe "#download_basename" do
      it "will be createable once the download directory is created" do
        expect(File.exists?(@filename)).to be_true
      end
    end
  end    

end

