require 'spec_helper'

describe WorkSearchForm do
  describe "searching" do
    let!(:collection) do
      FactoryGirl.create(:collection, id: 1)
    end

    let!(:work) do
      FactoryGirl.create(:work,
                         title: "There and back again",
                         authors: [Pseud.find_by(name: "JRR Tolkien") || FactoryGirl.create(:pseud, name: "JRR Tolkien")],
                         summary: "An unexpected journey",
                         fandom_string: "The Hobbit",
                         character_string: "Bilbo Baggins",
                         posted: true,
                         expected_number_of_chapters: 3,
                         complete: false,
                         language_id: 1)
    end

    let!(:second_work) do
      FactoryGirl.create(:work,
                         title: "Harry Potter and the Sorcerer's Stone",
                         authors: [Pseud.find_by(name: "JK Rowling") || FactoryGirl.create(:pseud, name: "JK Rowling")],
                         summary: "Mr and Mrs Dursley, of number four Privet Drive...",
                         fandom_string: "Harry Potter",
                         character_string: "Harry Potter, Ron Weasley, Hermione Granger",
                         posted: true,
                         language_id: 2)
    end

    before(:each) do
      # This doesn't work properly in the factory.
      second_work.collection_ids = [collection.id]
      second_work.save

      work.stat_counter.update_attributes(kudos_count: 1200, comments_count: 120, bookmarks_count: 12)
      second_work.stat_counter.update_attributes(kudos_count: 999, comments_count: 99, bookmarks_count: 9)
      update_and_refresh_indexes('work')
    end

    it "should find works that match" do
      work_search = WorkSearchForm.new(query: "Hobbit")
      expect(work_search.search_results).to include work
    end

    it "should not find works that don't match" do
      work_search = WorkSearchForm.new(query: "Hobbit")
      expect(work_search.search_results).not_to include second_work
    end

    describe "when searching unposted works" do
      before(:each) do
        work.update_attribute(:posted, false)
        update_and_refresh_indexes 'work'
      end

      it "should not return them by default" do
        work_search = WorkSearchForm.new(query: "Hobbit")
        expect(work_search.search_results).not_to include work
      end
    end

    describe "when searching restricted works" do
      before(:each) do
        work.update_attribute(:restricted, true)
        update_and_refresh_indexes 'work'
      end

      it "should not return them by default" do
        work_search = WorkSearchForm.new(query: "Hobbit")
        expect(work_search.search_results).not_to include work
      end

      it "should return them when asked" do
        work_search = WorkSearchForm.new(query: "Hobbit", show_restricted: true)
        expect(work_search.search_results).to include work
      end
    end

    describe "when searching incomplete works" do
      it "should not return them when asked for complete works" do
        work_search = WorkSearchForm.new(query: "Hobbit", complete: true)
        expect(work_search.search_results).not_to include work
      end
    end

    describe "when searching by title" do
      it "should match partial titles" do
        work_search = WorkSearchForm.new(title: "back again")
        expect(work_search.search_results).to include work
      end

      it "should not match fields other than titles" do
        work_search = WorkSearchForm.new(title: "Privet Drive")
        expect(work_search.search_results).not_to include second_work
      end
    end

    describe "when searching by author" do
      it "should match partial author names" do
        work_search = WorkSearchForm.new(creators: "Rowling")
        expect(work_search.search_results).to include second_work
      end

      it "should not match fields other than authors" do
        work_search = WorkSearchForm.new(creators: "Baggins")
        expect(work_search.search_results).not_to include work
      end

      it "should turn - into NOT" do
        work_search = WorkSearchForm.new(creators: "-Tolkien")
        expect(work_search.search_results).not_to include work
      end
    end

    describe "when searching by language" do
      it "should only return works in that language" do
        work_search = WorkSearchForm.new(language_id: 1)
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
    end

    describe "when searching by fandom" do
      it "should only return works in that fandom" do
        work_search = WorkSearchForm.new(fandom_names: "Harry Potter")
        expect(work_search.search_results).not_to include work
        expect(work_search.search_results).to include second_work
      end

      it "should not choke on exclamation points" do
        work_search = WorkSearchForm.new(fandom_names: "Potter!")
        expect(work_search.search_results).to include second_work
        expect(work_search.search_results).not_to include work
      end
    end

    describe "when searching by collection" do
      it "should only return works in that collection" do
        work_search = WorkSearchForm.new(collection_ids: [1])
        expect(work_search.search_results).to include second_work
        expect(work_search.search_results).not_to include work
      end
    end

    describe "when searching by word count" do
      before(:each) do
        work.chapters.first.update_attributes(content: "This is a work with a word count of ten.", posted: true)
        work.save

        second_work.chapters.first.update_attributes(content: "This is a work with a word count of fifteen which is more than ten.", posted: true)
        second_work.save

        update_and_refresh_indexes 'work'
      end

      it "should find the right works less than a given number" do
        work_search = WorkSearchForm.new(word_count: "<13")

        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
      it "should find the right works more than a given number" do
        work_search = WorkSearchForm.new(word_count: "> 10")
        expect(work_search.search_results).not_to include work
        expect(work_search.search_results).to include second_work
      end

      it "should find the right works within a range" do
        work_search = WorkSearchForm.new(word_count: "0-10")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
    end

    describe "when searching by kudos count" do
      it "should find the right works less than a given number" do
        work_search = WorkSearchForm.new(kudos_count: "< 1,000")
        expect(work_search.search_results).to include second_work
        expect(work_search.search_results).not_to include work
      end
      it "should find the right works more than a given number" do
        work_search = WorkSearchForm.new(kudos_count: "> 999")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end

      it "should find the right works within a range" do
        work_search = WorkSearchForm.new(kudos_count: "1,000-2,000")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
    end

    describe "when searching by comments count" do
      it "should find the right works less than a given number" do
        work_search = WorkSearchForm.new(comments_count: "< 100")
        expect(work_search.search_results).to include second_work
        expect(work_search.search_results).not_to include work
      end
      it "should find the right works more than a given number" do
        work_search = WorkSearchForm.new(comments_count: "> 99")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end

      it "should find the right works within a range" do
        work_search = WorkSearchForm.new(comments_count: "100-2,000")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
    end

    describe "when searching by bookmarks count" do
      it "should find the right works less than a given number" do
        work_search = WorkSearchForm.new(bookmarks_count: "< 10")
        expect(work_search.search_results).to include second_work
        expect(work_search.search_results).not_to include work
      end
      it "should find the right works more than a given number" do
        work_search = WorkSearchForm.new(bookmarks_count: ">9")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end

      it "should find the right works within a range" do
        work_search = WorkSearchForm.new(bookmarks_count: "10-20")
        expect(work_search.search_results).to include work
        expect(work_search.search_results).not_to include second_work
      end
    end
  end

  describe "searching for authors who changes username" do
    let!(:user) { create(:user, login: "81_white_chain") }
    let!(:second_pseud) { create(:pseud, name: "peacekeeper", user: user) }
    let!(:work_by_default_pseud) { create(:posted_work, authors: [user.default_pseud]) }
    let!(:work_by_second_pseud) { create(:posted_work, authors: [second_pseud]) }

    before { run_all_indexing_jobs }

    it "matches only on their current username" do
      results = WorkSearchForm.new(creators: "81_white_chain").search_results
      expect(results).to include(work_by_default_pseud)
      expect(results).to include(work_by_second_pseud)

      user.reload
      user.login = "82_white_chain"
      user.save!
      run_all_indexing_jobs

      results = WorkSearchForm.new(creators: "81_white_chain").search_results
      expect(results).to be_empty

      results = WorkSearchForm.new(creators: "82_white_chain").search_results
      expect(results).to include(work_by_default_pseud)
      expect(results).to include(work_by_second_pseud)
    end
  end

  describe "sorting results" do
    describe "by authors" do
      before do
        %w(21st_wombat 007aardvark).each do |pseud_name|
          create(:posted_work, authors: [create(:pseud, name: pseud_name)])
        end
        run_all_indexing_jobs
      end

      it "returns all works in the correct order of sortable pseud values" do
        sorted_pseuds_asc = ["007aardvark", "21st_wombat"]

        work_search = WorkSearchForm.new(sort_column: "authors_to_sort_on")
        expect(work_search.search_results.map(&:authors_to_sort_on)).to eq sorted_pseuds_asc

        work_search = WorkSearchForm.new(sort_column: "authors_to_sort_on", sort_direction: "asc")
        expect(work_search.search_results.map(&:authors_to_sort_on)).to eq sorted_pseuds_asc

        work_search = WorkSearchForm.new(sort_column: "authors_to_sort_on", sort_direction: "desc")
        expect(work_search.search_results.map(&:authors_to_sort_on)).to eq sorted_pseuds_asc.reverse
      end
    end

    describe "by authors who changes username" do
      let!(:user_1) { create(:user, login: "cioelle") }
      let!(:user_2) { create(:user, login: "ruth") }

      before do
        create(:posted_work, authors: [user_1.default_pseud])
        create(:posted_work, authors: [user_2.default_pseud])
        run_all_indexing_jobs
      end

      it "returns all works in the correct order of sortable pseud values" do
        work_search = WorkSearchForm.new(sort_column: "authors_to_sort_on")
        expect(work_search.search_results.map(&:authors_to_sort_on)).to eq ["cioelle", "ruth"]

        user_1.login = "yabalchoath"
        user_1.save!
        run_all_indexing_jobs

        work_search = WorkSearchForm.new(sort_column: "authors_to_sort_on")
        expect(work_search.search_results.map(&:authors_to_sort_on)).to eq ["ruth", "yabalchoath"]
      end
    end
  end
end
