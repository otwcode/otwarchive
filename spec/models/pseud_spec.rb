require "spec_helper"

describe Pseud do
  it { is_expected.to have_many(:gifts).conditions(rejected: false).dependent(:destroy) }
  it { is_expected.to have_many(:rejected_gifts).conditions(rejected: true).dependent(:destroy) }

  it "has a valid factory" do
    expect(build(:pseud)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:pseud, name: nil)).to be_invalid
  end

  it "is invalid if there are special characters" do
    expect(build(:pseud, name: "*pseud*")).to be_invalid
  end

  describe "save" do
    context "when the pseud is valid" do
      let(:pseud) { build(:pseud) }

      it "succeeds" do
        expect(pseud).to be_valid_verbose
        expect(pseud.save).to be_truthy
        expect(pseud.errors).to be_empty
      end
    end

    context "when the icon alt text is too long" do
      let(:pseud) { build(:pseud, icon_alt_text: "a" * 251) }

      it "fails" do
        expect(pseud.save).to be_falsey
        expect(pseud.errors[:icon_alt_text]).not_to be_empty
      end
    end

    context "when the icon comment text is too long" do
      let(:pseud) { build(:pseud, icon_comment_text: "a" * 51) }

      it "fails" do
        expect(pseud.save).to be_falsey
        expect(pseud.errors[:icon_comment_text]).not_to be_empty
      end
    end
  end

  describe "touch_comments" do
    let(:pseud) { create(:pseud) }
    let!(:comment) { create(:comment, pseud: pseud) }

    it "modifies the updated_at of associated comments" do
      # Without this, the in-memory pseud has 0 comments and the test fails.
      pseud.reload
      travel(1.day)
      expect do
        pseud.update!(name: "New Name")
      end.to change { comment.reload.updated_at }
    end
  end

  describe ".default_alphabetical" do
    let(:user) { create(:user, login: "Zaphod") }
    let(:subject) { user.pseuds.default_alphabetical }

    before do
      create(:pseud, user: user, name: "Slartibartfast")
      create(:pseud, user: user, name: "Agrajag")
      create(:pseud, user: user, name: "Betelgeuse")
      allow(ArchiveConfig).to receive(:ITEMS_PER_PAGE).and_return(3)
    end

    it "gets default pseud, then all pseuds in alphabetical order" do
      expect(subject.map(&:name)).to eq(%w[Zaphod Agrajag Betelgeuse Slartibartfast])
    end
  end

  describe ".abbreviated_list" do
    let(:user) { create(:user, login: "Zaphod") }
    let(:subject) { user.pseuds.abbreviated_list }

    before do
      create(:pseud, user: user, name: "Slartibartfast")
      create(:pseud, user: user, name: "Agrajag")
      create(:pseud, user: user, name: "Betelgeuse")
      allow(ArchiveConfig).to receive(:ITEMS_PER_PAGE).and_return(3)
    end

    it "gets default pseud, then shortened alphabetical list of other pseuds" do
      expect(subject.map(&:name)).to eq(%w[Zaphod Agrajag Betelgeuse])
      expect(subject.map(&:name)).not_to include("Slartibartfast")
      expect(subject.length).to eq(ArchiveConfig.ITEMS_PER_PAGE)
    end
  end

  describe "#clear_icon" do
    subject { create(:pseud, icon_alt_text: "icon alt", icon_comment_text: "icon comment") }

    before do
      subject.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
    end

    context "when delete_icon is false" do
      it "does not clear the icon, icon alt, or icon comment" do
        subject.clear_icon
        expect(subject.icon.attached?).to be(true)
        expect(subject.icon_alt_text).to eq("icon alt")
        expect(subject.icon_comment_text).to eq("icon comment")
      end
    end

    context "when delete_icon is true" do
      before do
        subject.delete_icon = 1
      end

      it "clears the icon, icon alt, and icon comment" do
        subject.clear_icon
        expect(subject.icon.attached?).to be(false)
        expect(subject.icon_alt_text).to be_nil
        expect(subject.icon_comment_text).to be_nil
      end
    end
  end
end
