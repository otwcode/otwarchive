require "spec_helper"

describe Creatorship do
  describe "#destroy" do
    context "when the creation is a work" do
      let(:creation) { create(:work, authors: [build(:pseud), build(:pseud)]) }
      let(:creatorship) { creation.creatorships.first }
      
      context "when the creatorship is approved" do
        before do
          creatorship.accept!
        end
  
        it "saves the original creator" do
          original_creator = creatorship.pseud.user
          creatorship.destroy!
          expect(creation.original_creators.length).to eq(1)
          expect(creation.original_creators.first.user).to eq(original_creator)
        end
      end
  
      context "when the creatorship is not approved" do
        before do
          creatorship.approved = false
          creatorship.save!(validate: false)
        end

        it "does not save the original creator" do
          expect { creatorship.destroy! }.not_to change { creation.original_creators }
        end
      end
    end
  end

  describe "busting anonymous creator comment caches (AO3-7536)" do
    let(:work) do
      create(:work, authors: [create(:pseud), create(:pseud)],
                    collections: [create(:anonymous_collection)])
    end
    let(:creatorship) { work.creatorships.last }
    let!(:comment) do
      create(:comment, commentable: work.first_chapter, pseud: creatorship.pseud)
    end

    it "touches the removed creator's comments when their creatorship is destroyed" do
      travel(1.second) do
        expect { creatorship.destroy! }
          .to change { comment.reload.updated_at }
      end
    end

    it "touches the accepting creator's comments when an invite is approved" do
      invited = create(:user)
      invite = work.creatorships.create!(pseud: invited.default_pseud)
      invite.update_column(:approved, false)
      invited_comment = create(:comment, commentable: work.first_chapter,
                                         pseud: invited.default_pseud)

      travel(1.second) do
        expect { invite.reload.accept! }
          .to change { invited_comment.reload.updated_at }
      end
    end

    it "does not touch comments when the work is not anonymous" do
      plain_work = create(:work, authors: [create(:pseud), create(:pseud)])
      plain_creatorship = plain_work.creatorships.last
      plain_comment = create(:comment, commentable: plain_work.first_chapter,
                                       pseud: plain_creatorship.pseud)

      travel(1.second) do
        expect { plain_creatorship.destroy! }
          .not_to change { plain_comment.reload.updated_at }
      end
    end
  end
end
