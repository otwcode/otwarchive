require "spec_helper"

describe BookmarksHelper do
  let(:bookmarker) { create(:user) }
  let(:external_work_bookmark) { create(:external_work_bookmark, pseud: bookmarker.default_pseud) }
  let(:series_bookmark) { create(:series_bookmark, pseud: bookmarker.default_pseud) }
  let(:work_bookmark) { create(:bookmark, pseud: bookmarker.default_pseud) }
  let(:external_work) { external_work_bookmark.bookmarkable }
  let(:series) { series_bookmark.bookmarkable }
  let(:series_creator) { series.users.first }
  let(:work) { work_bookmark.bookmarkable }
  let(:work_creator) { work.users.first }


  describe "#css_classes_for_bookmark_blurb" do
    let(:default_classes) { "bookmark blurb group" }

    context "when bookmarkable is ExternalWork" do
      it "returns string with default classes, creation info, and bookmarker info" do
        result = helper.css_classes_for_bookmark_blurb(external_work_bookmark)
        expect(result).to eq("#{default_classes} external-work-#{external_work.id} user-#{bookmarker.id}")
      end
    end

    context "when bookmarkable is Series" do
      it "returns string with default classes, creation and creator info, and bookmarker info" do
        result = helper.css_classes_for_bookmark_blurb(series_bookmark)
        expect(result).to eq("#{default_classes} series-#{series.id} user-#{series_creator.id} user-#{bookmarker.id}")
      end
    end

    context "when bookmarkable is Work" do
      it "returns string with default classes, creation and creator info, and bookmarker info" do
        result = helper.css_classes_for_bookmark_blurb(work_bookmark)
        expect(result).to eq("#{default_classes} work-#{work.id} user-#{work_creator.id} user-#{bookmarker.id}")
      end
    end
  end

  describe "#css_classes_for_bookmarkable_blurb" do
    let(:default_classes) { "bookmark blurb group" }

    context "when bookmarkable is ExternalWork" do
      it "returns string with default classes and creation info" do
        result = helper.css_classes_for_bookmarkable_blurb(external_work_bookmark)
        expect(result).to eq("#{default_classes} external-work-#{external_work.id}")
      end
    end

    context "when bookmarkable is Series" do
      it "returns string with default classes and creation and creator info" do
        result = helper.css_classes_for_bookmarkable_blurb(series_bookmark)
        expect(result).to eq("#{default_classes} series-#{series.id} user-#{series_creator.id}")
      end
    end

    context "when bookmarkable is Work" do
      it "returns string with default classes and creation and creator info" do
        result = helper.css_classes_for_bookmarkable_blurb(work_bookmark)
        expect(result).to eq("#{default_classes} work-#{work.id} user-#{work_creator.id}")
      end
    end
  end

  describe "#css_classes_for_bookmark_blurb_short" do 
    let(:default_classes) { "user short blurb group" }

    context "when logged in as bookmarker" do
      before do
        allow(helper).to receive(:current_user).and_return(bookmarker)
      end

      context "when bookmarkable is ExternalWork" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(external_work_bookmark)
          expect(result).to eq("own #{default_classes} user-#{bookmarker.id}")
        end
      end

      context "when bookmarkable is Series" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(series_bookmark)
          expect(result).to eq("own #{default_classes} user-#{bookmarker.id}")
        end
      end

      context "when bookmarkable is Work" do
        it "returns string with default classes, bookmarker info, and ownership indicator" do
          result = helper.css_classes_for_bookmark_blurb_short(work_bookmark)
          expect(result).to eq("own #{default_classes} user-#{bookmarker.id}")
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
          expect(result).to eq("#{default_classes} user-#{bookmarker.id}")
        end
      end

      context "when bookmarkable is Series" do
        it "returns string with default classes and bookmarker info" do
          result = helper.css_classes_for_bookmark_blurb_short(series_bookmark)
          expect(result).to eq("#{default_classes} user-#{bookmarker.id}")
        end
      end

      context "when bookmarkable is Work" do
        it "returns string with default classes and bookmarker info" do
          result = helper.css_classes_for_bookmark_blurb_short(work_bookmark)
          expect(result).to eq("#{default_classes} user-#{bookmarker.id}")
        end
      end
    end
  end
end
