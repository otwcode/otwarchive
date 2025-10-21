require "spec_helper"

describe Collection do
  before do
    @collection = FactoryBot.create(:collection)
  end

  describe "collections with challenges" do
    [GiftExchange, PromptMeme].each do |challenge_klass|
      %w[true false].each do |moderated_status|
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

  describe "updated at timestamps for collection preferences" do
    let(:preference) { create(:collection_preference, collection: @collection, unrevealed: true, anonymous: true) }

    it "sets unrevealed_updated_at and anonymous_updated_at to nil on creation" do
      expect(preference.unrevealed_updated_at).to eq(nil)
      expect(preference.anonymous_updated_at).to eq(nil)
    end

    it "updates unrevealed_updated_at when unrevealed changes" do
      preference.update!(unrevealed: !preference.unrevealed)

      preference.reload

      expect(preference.unrevealed_updated_at).to eq(preference.updated_at)
    end

    it "updates anonymous_updated_at when anonymous changes" do
      preference.update!(anonymous: !preference.anonymous)

      preference.reload

      expect(preference.anonymous_updated_at).to eq(preference.updated_at)
    end

    it "does not update timestamps when other attributes change" do
      old_unrevealed = preference.unrevealed_updated_at
      old_anonymous  = preference.anonymous_updated_at

      preference.update!(moderated: !preference.moderated)

      preference.reload

      expect(preference.unrevealed_updated_at).to eq(old_unrevealed)
      expect(preference.anonymous_updated_at).to eq(old_anonymous)
    end

    it "calls reveal! when unrevealed is changed to false" do
      collection_spy = preference.collection
      allow(collection_spy).to receive(:reveal!)

      preference.update!(unrevealed: false)

      expect(collection_spy).to have_received(:reveal!)
    end

    it "calls reveal_authors! when anonymous is changed to false" do
      collection_spy = preference.collection
      allow(collection_spy).to receive(:reveal_authors!)

      preference.update!(anonymous: false)

      expect(collection_spy).to have_received(:reveal_authors!)
    end

    it "does not call reveal methods when flags are unchanged" do
      allow(preference.collection).to receive(:reveal!)
      allow(preference.collection).to receive(:reveal_authors!)

      preference.update!(moderated: true)

      expect(preference.collection).not_to have_received(:reveal!)
      expect(preference.collection).not_to have_received(:reveal_authors!)
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

    it "disallows invalid header image urls" do
      collection.header_image_url = "https://example.com/image.webp"
      expect(collection).not_to be_valid
      expect(collection.errors.full_messages).to include("Header image URL can only point to a gif, jpg, jpeg, or png file.")
    end

    it "allows jpeg header image urls" do
      collection.header_image_url = "https://example.com/image.jpeg"
      expect(collection).to be_valid
    end

    it "allows jpg header image urls" do
      collection.header_image_url = "https://example.com/image.jpg"
      expect(collection).to be_valid
    end
    
    it "raises error when multifandom is nil" do
      expect { create(:collection, multifandom: nil) }
        .to raise_error(ActiveRecord::NotNullViolation)
    end

    it "raises error when open_doors is nil" do
      expect { create(:collection, open_doors: nil) }
        .to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe "#clear_icon" do
    subject { create(:collection, icon_alt_text: "icon alt", icon_comment_text: "icon comment") }

    before do
      subject.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
    end

    context "when delete_icon is false" do
      it "does not clear the icon, icon alt, or icon comment" do
        subject.clear_icon
        expect(subject.icon.attached?).to be(true)
        expect(subject.icon_alt_text).to eq("icon alt")
        expect(subject.icon_comment_text).to eq("icon comment")
      end
    end

    context "when delete_icon is true" do
      before do
        subject.delete_icon = 1
      end

      it "clears the icon, icon alt, and icon comment" do
        subject.clear_icon
        expect(subject.icon.attached?).to be(false)
        expect(subject.icon_alt_text).to be_nil
        expect(subject.icon_comment_text).to be_nil
      end
    end
  end

  describe "#general_works_count" do
    let(:collection) { create(:collection) }

    shared_examples "does not count the work" do
      it "does not include the work in the count" do
        expect(collection.general_works_count).to eq(0)
      end
    end

    context "when the collection includes a restricted work" do
      let(:work) { create(:work, restricted: true) }

      before do
        work.collections << collection
      end

      it "includes the work in the count" do
        expect(collection.general_works_count).to eq(1)
      end
    end

    context "when the collection includes a hidden work" do
      let(:work) { create(:work, hidden_by_admin: true) }

      before do
        work.collections << collection
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a draft work" do
      let(:work) { create(:work, posted: false) }

      before do
        work.collections << collection
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work rejected by collection" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(collection_approval_status: :rejected)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work rejected by user" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(user_approval_status: :rejected)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes an invited public work" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(collection_approval_status: :approved, user_approval_status: :unreviewed)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
      end

      it "includes the work in the count" do
        expect(collection.general_works_count).to eq(1)
      end
    end

    context "when the collection includes a subcollection with a work" do
      let(:subcollection) { create_invalid(:collection, parent: collection) }
      let(:work) { create(:work) }

      before do
        work.collections << subcollection
      end

      it "includes the subcollection's work in the count" do
        expect(collection.general_works_count).to eq(1)
      end

      context "when the collection contains the same work as the subcollection" do
        before do
          work.collections << collection
        end

        it "does not double count the work" do
          expect(collection.general_works_count).to eq(1)
        end
      end
    end
  end

  describe "#public_works_count" do
    let(:collection) { create(:collection) }

    shared_examples "does not count the work" do
      it "does not include the work in the count" do
        expect(collection.public_works_count).to eq(0)
      end
    end

    context "when the collection includes a restricted work" do
      let(:work) { create(:work, restricted: true) }

      before do
        work.collections << collection
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work rejected by collection" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(collection_approval_status: :rejected)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work rejected by user" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(user_approval_status: :rejected)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes an invited public work" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
        work.collection_items.update!(collection_approval_status: :approved, user_approval_status: :unreviewed)
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a public work" do
      let(:work) { create(:work) }

      before do
        work.collections << collection
      end

      it "includes the work in the count" do
        expect(collection.public_works_count).to eq(1)
      end
    end

    context "when the collection includes a hidden work" do
      let(:work) { create(:work, hidden_by_admin: true) }

      before do
        work.collections << collection
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a draft work" do
      let(:work) { create(:work, posted: false) }

      before do
        work.collections << collection
      end

      it_behaves_like "does not count the work"
    end

    context "when the collection includes a subcollection with a work" do
      let(:subcollection) { create_invalid(:collection, parent: collection) }
      let(:work) { create(:work) }

      before do
        work.collections << subcollection
      end

      it "includes the subcollection's work in the count" do
        expect(collection.public_works_count).to eq(1)
      end

      context "when the collection contains the same work as the subcollection" do
        before do
          work.collections << collection
        end

        it "does not double count the work" do
          expect(collection.general_works_count).to eq(1)
        end
      end
    end
  end

  describe "#general_bookmarked_items_count" do
    let(:collection) { create(:collection) }

    context "when the collection contains a public bookmark" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
      end

      it "counts the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(1)
      end
    end

    context "when the collection contains a private bookmark" do
      let(:bookmark) { create(:bookmark, private: true) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a hidden bookmark" do
      let(:bookmark) { create(:bookmark, hidden_by_admin: true) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark rejected by collection" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(collection_approval_status: :rejected)
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark rejected by user" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(user_approval_status: :rejected)
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark awaiting collection approval" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(collection_approval_status: :unreviewed, user_approval_status: :approved)
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of a hidden work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, hidden_by_admin: true)) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of an unposted work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, posted: false)) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of a restricted work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, restricted: true)) }

      before do
        bookmark.collections << collection
      end

      it "counts the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(1)
      end
    end

    context "when the collection contains a subcollection with a bookmark" do
      let(:subcollection) { create_invalid(:collection, parent: collection) }
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << subcollection
      end

      it "counts the bookmark" do
        expect(collection.general_bookmarked_items_count).to eq(1)
      end

      context "when the collection contains the same bookmark" do
        before do
          bookmark.collections << collection
        end

        it "does not double count the bookmark" do
          expect(collection.general_bookmarked_items_count).to eq(1)
        end
      end
    end
  end

  describe "#public_bookmarked_items_count" do
    let(:collection) { create(:collection) }

    context "when the collection contains an public bookmark" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
      end

      it "counts the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(1)
      end
    end

    context "when the collection contains a private bookmark" do
      let(:bookmark) { create(:bookmark, private: true) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a hidden bookmark" do
      let(:bookmark) { create(:bookmark, hidden_by_admin: true) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark rejected by collection" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(collection_approval_status: :rejected)
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark rejected by user" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(user_approval_status: :rejected)
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a public bookmark awaiting collection approval" do
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << collection
        bookmark.collection_items.update!(collection_approval_status: :unreviewed, user_approval_status: :approved)
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of a hidden work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, hidden_by_admin: true)) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of an unposted work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, posted: false)) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a bookmark of a restricted work" do
      let(:bookmark) { create(:bookmark, bookmarkable: create(:work, restricted: true)) }

      before do
        bookmark.collections << collection
      end

      it "does not count the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(0)
      end
    end

    context "when the collection contains a subcollection with a bookmark" do
      let(:subcollection) { create_invalid(:collection, parent: collection) }
      let(:bookmark) { create(:bookmark) }

      before do
        bookmark.collections << subcollection
      end

      it "counts the bookmark" do
        expect(collection.public_bookmarked_items_count).to eq(1)
      end

      context "when the collection contains the same bookmark" do
        before do
          bookmark.collections << collection
        end

        it "does not double count the bookmark" do
          expect(collection.public_bookmarked_items_count).to eq(1)
        end
      end
    end
  end

  describe "#approved_works_count" do
    it "delegates to SearchCounts" do
      expect(SearchCounts).to receive(:work_count_for_collection).with(@collection).and_return(3)
      expect(@collection.approved_works_count).to eq(3)
    end
  end

  describe "#approved_bookmarked_items_count" do
    it "delegates to SearchCounts" do
      expect(SearchCounts).to receive(:bookmarkable_count_for_collection).with(@collection).and_return(5)
      expect(@collection.approved_bookmarked_items_count).to eq(5)
    end
  end
end
