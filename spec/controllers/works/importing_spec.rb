require 'spec_helper'

describe WorksController do
  include LoginMacros

  describe "import" do
    context "should return the right error messages" do
      let(:user) { create(:user) }

      before do
        fake_login_known_user(user)
      end

      it "when urls are empty" do
        params = { urls: "" }
        get :import, params
        expect(flash[:error]).to eq "Did you want to enter a URL?"
      end

      it "there is an external author name but importing_for_others is NOT turned on" do
        params = { urls: "url1, url2", external_author_name: "Foo", importing_for_others: false }
        get :import, params
        expect(flash[:error]).to start_with "You have entered an external author name"
      end

      it "there is an external author email but importing_for_others is NOT turned on" do
        params = { urls: "url1, url2", external_author_email: "Foo", importing_for_others: false }
        get :import, params
        expect(flash[:error]).to start_with "You have entered an external author name"
      end

      context "the current user is NOT an archivist" do
        it "should error when importing_for_others is turned on" do
          params = { urls: "url1, url2", importing_for_others: true }
          get :import, params
          expect(flash[:error]).to start_with "You may not import stories by other users"
        end

        it "should error when importing over the maximum number of works" do
          max = ArchiveConfig.IMPORT_MAX_WORKS
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "works" }
          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"
        end
      end

      context "the current user is an archivist" do
        it "should error when importing over the maximum number of works" do
          max = ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "works" }
          allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)

          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"

          allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
        end

        it "should error when importing over the maximum number of chapters" do
          max = ArchiveConfig.IMPORT_MAX_CHAPTERS
          urls = Array.new(max + 1) { |i| "url#{i}" }.join(", ")
          params = { urls: urls, importing_for_others: false, import_multiple: "chapters" }
          allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)

          get :import, params
          expect(flash[:error]).to start_with "You cannot import more than #{max}"

          allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
        end
      end
    end
  end

  describe "import_single" do
    it "should display the correct error when a timeout occurs" do
      allow_any_instance_of(StoryParser).to receive(:download_and_parse_story).and_raise(Timeout::Error)
      expect(controller.send(:import_single, ["url1"], {})).to rescue(:new_import)
      expect(flash[:error]).to start_with "Import has timed out"
      allow_any_instance_of(StoryParser).to receive(:download_and_parse_story).and_call_original
    end

    it "should display the correct error when a StoryParser error occurs" do
      allow_any_instance_of(StoryParser).to receive(:download_and_parse_story).and_raise(StoryParser::Error.new("message"))
      expect(controller.send(:import_single, ["url1"], {})).to rescue(:new_import)
      expect(flash[:error]).to start_with "We couldn't successfully import that work, sorry: message"
      allow_any_instance_of(StoryParser).to receive(:download_and_parse_story).and_call_original
    end
  end

  describe "import_multiple" do

  end
end
