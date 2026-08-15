# frozen_string_literal: true

require "spec_helper"

describe RelatedWork do
  it "has a valid factory" do
    expect(build(:related_work)).to be_valid
  end

  shared_examples "it prevents creation" do
    it "returns an error" do
      expect(related_work).to be_invalid
      expect(related_work.errors[:parent]).to contain_exactly("This work cannot be listed as an inspiration.")
    end
  end

  context "#check_parent_protected" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    let(:work) { create(:work, authors: [user1.default_pseud, user2.default_pseud, user3.default_pseud]) }
    let(:related_work) { build(:related_work, parent: work) }

    context "when a creator is protected" do
      let(:user2) { create(:protected_user) }

      it_behaves_like "it prevents creation"

      context "when creators are anonymous" do
        before { work.update!(collections: [build(:anonymous_collection)]) }

        it "is valid" do
          expect(related_work).to be_valid
        end
      end

      context "when the work is unrevealed" do
        before { work.update!(collections: [build(:unrevealed_collection)]) }

        it "is valid" do
          expect(related_work).to be_valid
        end
      end
    end

    context "when multiple creators are protected" do
      let(:user1) { create(:protected_user) }
      let(:user3) { create(:protected_user) }

      it_behaves_like "it prevents creation"
    end

    context "when no creators are protected" do
      it "is valid" do
        expect(related_work).to be_valid
      end
    end
  end

  context "#check_parent_visible" do
    let(:user) { create(:user) }

    let!(:parent_work) { create(:work) }
    let!(:child_work) { create(:work, authors: [user.default_pseud]) }
    let!(:related_work) { build(:related_work, work: child_work, parent: parent_work) }

    before do
      User.current_user = user
    end

    context "when the work is public" do
      it "is valid" do
        expect(related_work).to be_valid
      end
    end

    context "when a creator owns both the parent and the child" do
      let(:parent_work) { create(:work, authors: [user.default_pseud]) }

      context "when the parent work is hidden" do
        let(:parent_work) { create(:work, authors: [user.default_pseud], hidden_by_admin: true) }

        # since hidden related works are completely invisible to all users on public work pages
        it_behaves_like "it prevents creation"
      end

      context "when the parent work is a draft" do
        let(:parent_work) { create(:draft, authors: [user.default_pseud]) }

        it "is valid" do
          expect(related_work).to be_valid
        end
      end
    end

    context "when the parent work is hidden" do
      let(:parent_work) { create(:work, hidden_by_admin: true) }

      it_behaves_like "it prevents creation"
    end

    context "when the parent work is a draft" do
      let(:parent_work) { create(:draft) }

      it_behaves_like "it prevents creation"
    end
  end
end
