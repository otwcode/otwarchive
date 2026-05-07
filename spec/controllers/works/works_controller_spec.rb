# frozen_string_literal: true

require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #navigate" do
    context "denies access for work that isn't visible to user" do
      subject { get :navigate, params: { id: work.id } }
      let(:success) { expect(response).to render_template("navigate") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :navigate, params: { id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  describe ".import_multiple" do
    context "when the import has a failure from at least one URL" do
      before do
        allow_any_instance_of(StoryParser).to receive(:import_from_urls).and_return([
          [],
          urls,
          [["failedurl1 first error", "failedurl1 second error"], ["failedurl2 first error"]]
        ])
        allow(controller).to receive(:render).with(:new_import)
      end
      let(:urls) { ["https://www.failedurl1.com", "https://www.failedurl2.com"] }

      it 'returns a well-formatted error message' do
        expect(controller).to receive(:render).with(:new_import)
        controller.send(:import_multiple, urls, {})
        expect(flash[:error]).to eq(
          "<h3>Failed Imports</h3>" \
          "<dl>" \
          "<dt>https://www.failedurl1.com</dt>" \
          "<ul>" \
          "<li>failedurl1 first error</li>\n" \
          "<li>failedurl1 second error</li>" \
          "</ul>\n" \
          "<dt>https://www.failedurl2.com</dt>" \
          "<ul>" \
          "<li>failedurl2 first error</li>" \
          "</ul>" \
          "</dl>"
       )
      end
    end
  end
end
