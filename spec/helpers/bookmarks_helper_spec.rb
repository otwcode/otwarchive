require "spec_helper"

describe BookmarksHelper do
  describe "#bookmark_if_exists" do
    before do
      allow(helper).to receive(:current_user) { user.reload }
      allow(helper).to receive(:logged_in?) { user.present? }
    end

    let(:work) { create(:work) }

    context "when logged out" do
      let(:user) { nil }

      it "returns nil" do
        expect(helper.bookmark_if_exists(work)).to eq(nil)
      end
    end

    context "when logged in" do
      let(:user) { create(:user) }
      let(:default) { user.default_pseud }
      let(:pseud) { create(:pseud, user: user) }

      context "when the user has no bookmarks" do
        it "returns nil" do
          expect(helper.bookmark_if_exists(work)).to eq(nil)
        end
      end

      context "when the user has a bookmark for another work" do
        let!(:bookmark) { create(:bookmark, pseud: default) }

        it "returns nil" do
          expect(helper.bookmark_if_exists(work)).to eq(nil)
        end
      end

      context "when the user has one bookmark for the work" do
        let!(:bookmark) do
          create(:bookmark, bookmarkable: work, pseud: default)
        end

        it "returns the bookmark" do
          expect(helper.bookmark_if_exists(work)).to eq(bookmark)
        end
      end

      context "when the user has multiple bookmarks for the same work" do
        context "when one of the bookmarks is by the user's default pseud" do
          let!(:default_bookmark) do
            create(:bookmark, bookmarkable: work, pseud: default)
          end

          let!(:other_bookmark) do
            create_invalid(:bookmark, bookmarkable: work, pseud: pseud)
          end

          it "returns the bookmark by the default pseud" do
            expect(helper.bookmark_if_exists(work)).to eq(default_bookmark)
          end
        end

        context "when all of the bookmarks are by the user's default pseud" do
          let!(:older_bookmark) do
            create(:bookmark, bookmarkable: work, pseud: default)
          end

          let!(:newer_bookmark) do
            create_invalid(:bookmark, bookmarkable: work, pseud: default)
          end

          it "returns the most recent bookmark" do
            expect(helper.bookmark_if_exists(work)).to eq(newer_bookmark)
          end
        end

        context "when none of the bookmarks are by the user's default pseud" do
          let!(:older_bookmark) do
            create(:bookmark, bookmarkable: work, pseud: pseud)
          end

          let!(:newer_bookmark) do
            create_invalid(:bookmark, bookmarkable: work, pseud: pseud)
          end

          it "returns the most recent bookmark" do
            expect(helper.bookmark_if_exists(work)).to eq(newer_bookmark)
          end
        end
      end
    end
  end
end
