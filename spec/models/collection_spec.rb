require 'spec_helper'

describe Collection do

  before do
    @collection = FactoryBot.create(:collection)
  end

  describe "collections with challenges" do
    [GiftExchange, PromptMeme].each do |challenge_klass|
      ["true","false"].each do |moderated_status|
        describe "of type #{challenge_klass.name}" do
          before do
            @collection.challenge = challenge_klass.new
            @collection.collection_preference.moderated = moderated_status
            @challenge = @collection.challenge
            @challenge.signups_open_at = Time.now - 3.days
            @challenge.signups_close_at = Time.now + 3.days
            @collection.save
          end

          it "should correctly identify the collection challenge type" do
            expect(@collection.gift_exchange?).to eq(@challenge.is_a?(GiftExchange))
            expect(@collection.prompt_meme?).to eq(@challenge.is_a?(PromptMeme))
          end

          describe "with open signup" do
            before do
              @challenge.signup_open = true
            end

            describe "and close date in the future" do
              before do
                @challenge.signups_open_at = Time.now - 3.days
                @challenge.signups_close_at = Time.now + 3.days
                @challenge.save
              end

              it "should be listed as open" do
                expect(Collection.signup_open(@challenge.class.name)).to include(@collection)
              end
            end

            describe "and close date in the past" do
              before do
                @challenge.signups_close_at = 2.days.ago
                @challenge.signups_open_at = 8.days.ago
                @challenge.signup_open = false
                @challenge.save
                @challenge.signup_open = true
                @challenge.save
              end

              it "should not be listed as open" do
                expect(Collection.signup_open(@challenge.class.name)).not_to include(@collection)
              end

            end
          end

          describe "with closed signup" do
            before do
              @challenge.signup_open = false
              @challenge.save
            end

            it "should not be listed as open" do
              expect(Collection.signup_open(@challenge.class.name)).not_to include(@collection)
            end
          end
        end
      end # moderated_status loop
    end # challenges type loop
  end

  describe "all_bookmarked_items_count" do
    let(:collection) { create(:collection) }

    it "does not include bookmarks of deleted works" do
      work = create(:work)
      create(:bookmark, collections: [collection], bookmarkable: work)
      expect do
        work.destroy
      end.to change { collection.all_bookmarked_items_count }.from(1).to(0)
    end

    it "does not include multiple bookmarks of the same work" do
      work = create(:work)
      create(:bookmark, collections: [collection], bookmarkable: work)
      create(:bookmark, collections: [collection], bookmarkable: work)
      expect(collection.all_bookmarked_items_count).to eq 1
    end

    it "doesn't include private bookmarks" do
      create(:bookmark, collections: [collection], private: true)
      expect(collection.all_bookmarked_items_count).to eq 0
    end

    it "includes bookmarks of restricted works only when logged-in" do
      work = create(:work, restricted: true)
      create(:bookmark, collections: [collection], bookmarkable: work)
      expect do
        User.current_user = User.new
      end.to change { collection.all_bookmarked_items_count }.from(0).to(1)
    end

    it "counts bookmarks of all types" do
      %i[work series_with_a_work external_work].each do |factory|
        item = create(factory)
        create(:bookmark, collections: [collection], bookmarkable: item)
      end
      expect(collection.all_bookmarked_items_count).to eq 3
    end
  end

  describe "save" do
    let(:collection) { create(:collection) }

    it "checks the tag limit" do
      collection.tag_string = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11"
      expect(collection.save).to be_falsey
      expect(collection.errors.full_messages).to \
        include /Sorry, a collection can only have 10 tags./
    end
  end
end
