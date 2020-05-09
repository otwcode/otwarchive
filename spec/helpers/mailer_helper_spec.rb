require "spec_helper"

describe MailerHelper do
  describe "style_creation_link" do
    it "nests red link inside bold inside italics" do
      work = create(:work)
      expect(style_creation_link(work.title, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i>")
    end
  end
end
