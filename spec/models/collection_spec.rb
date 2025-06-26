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
