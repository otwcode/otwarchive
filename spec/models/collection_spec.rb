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
end
