require 'spec_helper'

describe WorkSearch do

  before(:each) do
    Tire.index(Work.index_name).delete
    load File.expand_path('../../../app/models/work.rb', __FILE__)
    Work.import
  end

  after(:each) do
    Work.destroy_all
    Tire.index(Work.index_name).delete
  end

  let!(:work) do
    Factory.create(:work,
      title: "There and back again",
      authors: [ Factory.create(:pseud, name: "JRR Tolkien") ],
      summary: "An unexpected journey",
      fandom_string: "The Hobbit",
      character_string: "Bilbo Baggins",
      posted: true,
      expected_number_of_chapters: 3,
      complete: false
    )
  end

  let!(:second_work) do
    Factory.create(:work,
      title: "Harry Potter and the Sorcerer's Stone",
      authors: [ Factory.create(:pseud, name: "JK Rowling") ],
      summary: "Mr and Mrs Dursley, of number four Privet Drive...",
      fandom_string: "Harry Potter",
      character_string: "Harry Potter, Ron Weasley, Hermione Granger",
      posted: true
    )
  end

  describe '#search_results' do

    before(:each) do
      Work.tire.index.refresh
    end

    it "should find works that match" do
      work_search = WorkSearch.new(query: "Hobbit")
      work_search.search_results.should include work
    end

    it "should not find works that don't match" do
      work_search = WorkSearch.new(query: "Hobbit")
      work_search.search_results.should_not include second_work
    end

    describe "when searching unposted works" do
      before(:each) do
        work.update_attribute(:posted, false)
        Work.tire.index.refresh
      end

      it "should not return them by default" do
        work_search = WorkSearch.new(query: "Hobbit")
        work_search.search_results.should_not include work
      end
    end

    describe "when searching restricted works" do
      before(:each) do
        work.update_attribute(:restricted, true)
        Work.tire.index.refresh
      end

      it "should not return them by default" do
        work_search = WorkSearch.new(query: "Hobbit")
        work_search.search_results.should_not include work
      end

      it "should return them when asked" do
        work_search = WorkSearch.new(query: "Hobbit", show_restricted: true)
        work_search.search_results.should include work
      end
    end

    describe "when searching incomplete works" do
      it "should not return them when asked for complete works" do
        work_search = WorkSearch.new(query: "Hobbit", complete: true)
        work_search.search_results.should_not include work
      end
    end

    describe "when searching by title" do
      it "should match partial titles" do
        work_search = WorkSearch.new(title: "back again")
        work_search.search_results.should include work
      end

      it "should not match fields other than titles" do
        work_search = WorkSearch.new(title: "Privet Drive")
        work_search.search_results.should_not include second_work
      end
    end

    describe "when searching by author" do
      it "should match partial author names" do
        second_work.update_index
        work_search = WorkSearch.new(creator: "Rowling")
        work_search.search_results.should include second_work
      end

      it "should not match fields other than authors" do
        work.update_index
        work_search = WorkSearch.new(creator: "Baggins")
        work_search.search_results.should_not include work
      end

      it "should turn - into NOT" do
        work.update_index
        work_search = WorkSearch.new(creator: "-Tolkien")
        work_search.search_results.should_not include work
      end
    end

    describe "when searching by language" do
      it "should only return works in that language"
    end

    describe "when searching by fandom" do
      it "should only return works in that fandom" do
        work_search = WorkSearch.new(fandom_names: "Harry Potter")
        work_search.search_results.should_not include work
      end

      it "should not choke on exclamation points" do
        work_search = WorkSearch.new(fandom_names: "Potter!")
        work_search.search_results.should include second_work
      end
    end

    describe "when searching by collection" do
      it "should only return works in that collection"
    end

    describe "when searching by word count" do

    end

    describe "when searching by kudos count" do

    end

    describe "when searching by comments count" do

    end

    describe "when searching by bookmarks count" do

    end
  end

end
