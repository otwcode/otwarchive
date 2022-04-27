require "spec_helper"

describe CommentsHelper do
  describe "#commenter_id_for_css_classes" do
    context "when commenter is a user" do
      let(:user) { create(:user) }
      let(:comment) { create(:comment, pseud: user.default_pseud) }

      it "returns commenter id css class name" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq("user-#{user.id}")
      end

      context "when commenter is creator of work inside anonymous collection" do
        let(:anonymous_collection) { create(:anonymous_collection) }
        let(:work) { create(:work, authors: [user.default_pseud], collections: [anonymous_collection]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.last_posted_chapter) }
  
        it "returns nil" do
          expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
        end
      end
    end
    
    context "when commenter is a visitor" do
      let(:comment) { create(:comment, :by_guest) }

      it "returns nil" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
      end
    end
  end

  describe "#css_classes_for_comment" do
    context "when comment exists" do
      let(:user) { create(:user) }
      let(:comment) { create(:comment, pseud: user.default_pseud) }
      
      it "has classes" do
        expect(helper.css_classes_for_comment(comment)).to eq("comment group user-#{user.id}")
      end

      it "includes unreviewed class when comment is unreviewed" do
        comment.unreviewed = true
        expect(helper.css_classes_for_comment(comment)).to eq("unreviewed comment group user-#{user.id}")
      end
    end
  end
end