require "spec_helper"

describe "Works#show", :type => :request do
  let(:work) { create(:work) }
  let(:chapter) { work.chapters.first }

  context "when the first chapter of a work is unposted" do
    before do
      work.chapters.create(position: 1, posted: false, content: "Draft content")
      chapter.update(position: 2)
    end

    it "displays the first posted chapter" do
      get "/works/#{work.id}"
      expect(response).to render_template(:show)
      expect(response.body).to include(chapter.content)
      expect(response.body).not_to include("Draft content")
    end
  end
end
