require 'spec_helper'

describe Pseud do
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
    before do
      @user = User.new
      @user.login = "mynamepseud"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
      @user.save
    end

    before(:each) do
      @pseud = Pseud.new
      @pseud.user_id = @user.id
      @pseud.name = "MyName"
    end

    it "should save a minimalistic pseud" do
      @pseud.should be_valid_verbose
      expect(@pseud.save).to be_truthy
      @pseud.errors.should be_empty
    end

    it "should not save pseud with too-long alt text for icon" do
      @pseud.icon_alt_text = "Something that is too long blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah this needs 250 characters lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum"
      expect(@pseud.save).to be_falsey
      @pseud.errors[:icon_alt_text].should_not be_empty
    end

    it "should not save pseud with too-long comment text for icon" do
      @pseud.icon_comment_text = "Something that is too long blah blah blah blah blah blah this needs a mere 50 characters"
      expect(@pseud.save).to be_falsey
      @pseud.errors[:icon_comment_text].should_not be_empty
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
        pseud.update(name: "New Name")
      end.to change { comment.reload.updated_at }
    end
  end

  describe "#change_ownership" do
    let(:original_pseud) { create(:pseud) }
    let(:new_pseud) { create(:pseud) }

    context "when store_original_creator is false" do
      context "for a work" do
        let(:work) { create(:work, authors: [original_pseud]) }

        it "does not save the original creator" do
          original_pseud.change_ownership(work, new_pseud)
          expect(work.original_creators).to be_empty
        end
      end
    end

    context "when store_original_creator is true" do
      context "for a work" do
        let(:work) { create(:work, authors: [original_pseud]) }

        it "saves the original creator" do
          original_pseud.change_ownership(work, new_pseud, store_original_creator: true)
          original_user = original_pseud.user
          expect(work.original_creators)
            .to contain_exactly("#{original_user.id} (#{original_user.login})")
        end
      end

      context "for a series" do
        let(:series) { create(:series, authors: [original_pseud]) }

        it "does not error by attempting to set original creators" do
          expect do
            original_pseud.change_ownership(series, new_pseud, store_original_creator: true)
          end.not_to raise_error
        end
      end
    end
  end
end
