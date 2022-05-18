require "spec_helper"

describe BookmarksHelper do
  let(:user) { create(:user) }
  let(:external_work_bookmark) { create(:external_work_bookmark, pseud: user.default_pseud) }
  let(:series_bookmark) { create(:series_bookmark, pseud: user.default_pseud) }
  let(:work_bookmark) { create(:bookmark, pseud: user.default_pseud) }
  let(:external_work) { external_work_bookmark.bookmarkable }
  let(:series) { series_bookmark.bookmarkable }
  let(:work) { work_bookmark.bookmarkable }


  describe "#css_classes_for_bookmark_blurb" do
    context "when bookmarkable is ExternalWork" do
    end

    context "when bookmarkable is Series" do
    end

    context "when bookmarkable is Work" do
    end
  end

  describe "#css_classes_for_bookmarkable_blurb" do 
    context "when bookmarkable is ExternalWork" do
    end

    context "when bookmarkable is Series" do
    end

    context "when bookmarkable is Work" do
    end
  end

  describe "#css_classes_for_bookmark_blurb_short" do 
    let(:default_classes) { "user short blurb group" }

    context "when logged in as bookmarker" do
      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      context "when bookmarkable is ExternalWork" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(external_work_bookmark)
          expect(result).to eq("own #{default_classes} user-#{user.id}")
        end
      end

      context "when bookmarkable is Series" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(series_bookmark)
          expect(result).to eq("own #{default_classes} user-#{user.id}")
        end
      end

      context "when bookmarkable is Work" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(work_bookmark)
          expect(result).to eq("own #{default_classes} user-#{user.id}")
        end
      end
    end

    context "when not logged in as bookmarker" do
      before do
        allow(helper).to receive(:current_user)
      end

      context "when bookmarkable is ExternalWork" do
        it "returns string with default classes and bookmarker info" do
          result = helper.css_classes_for_bookmark_blurb_short(external_work_bookmark)
          expect(result).to eq("#{default_classes} user-#{user.id}")
        end
      end

      context "when bookmarkable is Series" do
        it "returns string with default classes and bookmarker info" do
          result = helper.css_classes_for_bookmark_blurb_short(series_bookmark)
          expect(result).to eq("#{default_classes} user-#{user.id}")
        end
      end

      context "when bookmarkable is Work" do
        it "returns string with default classes and bookmarker info" do
          result = helper.css_classes_for_bookmark_blurb_short(work_bookmark)
          expect(result).to eq("#{default_classes} user-#{user.id}")
        end
      end
    end
  end
end
