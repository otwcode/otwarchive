require 'spec_helper'
require 'support/login_macros'

describe ExternalAuthor do
  include LoginMacros

  describe "find_or_invite" do
    let(:unclaimed_user) { create(:user) }
    let(:claimed_user) { create(:user) }
    let(:unclaimed_ext_author) { create(:external_author, is_claimed: false) }
    let(:unclaimed_user_author) { create(:external_author, email: unclaimed_user.email, is_claimed: false) }
    let(:claimed_ext_author) { create(:external_author, user_id: claimed_user.id, is_claimed: true) }
    let(:archivist) { create(:archivist) }

    context "a user with a matching email exists" do
      subject { unclaimed_user_author }

      it "is automatically claimed by the user" do
        subject.find_or_invite(archivist)
        expect(subject.claimed?).to eq(true)
        expect(subject.user_id).to eq(unclaimed_user.id)
      end
    end

    context "a claimed external user with a matching email exists" do
      subject { claimed_ext_author }

      it "is automatically claimed by the corresponding user" do
        expect(subject).to receive(:claim!).with(claimed_user)
        subject.find_or_invite(archivist)
      end

      it "does NOT generate an invitation email" do
        expect(Invitation).to_not receive(:new)
        subject.find_or_invite(archivist)
      end
    end

    context "no external author or user with a matching email exists" do
      subject { unclaimed_ext_author }

      it "generates an invitation email" do
        expect(Invitation).to receive(:new).and_call_original
        subject.find_or_invite(archivist)
      end
    end

  end

  describe "orphan" do
    let!(:orphan_account) { create(:user, login: "orphan_account") }
    let(:archivist) { create(:archivist) }
    let(:external_author) { create(:external_author) }
    let(:external_author_name) { create(:external_author_name, external_author: external_author, name: "Old Pen Name") }
    let(:work) { create(:work, authors: [archivist.default_pseud]) }
    let!(:external_creatorship) do
      create(:external_creatorship,
             creation_id: work.id,
             external_author_name_id: external_author_name.id,
             archivist_id: archivist.id)
    end

    context "when remove_pseud is false" do
      it "moves the work to the orphan account under the original pen name" do
        external_author.orphan(false)
        expect(work.reload.pseuds.map(&:name)).to include("Old Pen Name")
        expect(work.pseuds.map(&:user_id)).to eq([orphan_account.id])
      end
    end

    context "when remove_pseud is true" do
      it "moves the work to the orphan account's default pseud" do
        external_author.orphan(true)
        expect(work.reload.pseuds).to eq([orphan_account.default_pseud])
      end
    end

    it "removes the connection between the work and the external author's email" do
      expect { external_author.orphan(false) }
        .to change { external_author.reload.works.count }.from(1).to(0)
      expect(ExternalCreatorship.exists?(external_creatorship.id)).to be false
    end

    it "prevents the work from being claimed back afterwards" do
      external_author.orphan(false)
      claiming_user = create(:user, email: external_author.email)

      expect(work.reload.pseuds.map(&:user_id)).not_to include(claiming_user.id)
      external_author.claim!(claiming_user)
      expect(work.reload.pseuds.map(&:user_id)).not_to include(claiming_user.id)
    end
  end
end
