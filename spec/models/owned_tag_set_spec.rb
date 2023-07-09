# frozen_string_literal: true

require "spec_helper"

describe OwnedTagSet do
  let(:owned_tag_set) { create(:owned_tag_set) }
  let(:user) { create(:user) }

  describe "#owner_changes=" do
    context "when assigning a user that is not an owner" do
      it "makes the user an owner" do
        owned_tag_set.update(owner_changes: user.login)
        expect(owned_tag_set.owners.reload).to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "makes the first user an owner" do
          owned_tag_set.update(owner_changes: user.login)
          expect(owned_tag_set.owners.reload).to include(user.default_pseud)
        end
      end
    end

    context "when assigning a user that is an owner" do
      before do
        owned_tag_set.add_owner(user.default_pseud)
        owned_tag_set.save
        owned_tag_set.reload
      end

      it "removes the user as an owner" do
        owned_tag_set.update(owner_changes: user.login)
        expect(owned_tag_set.owners.reload).not_to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "removes the first user as an owner" do
          owned_tag_set.update(owner_changes: user.login)
          expect(owned_tag_set.owners.reload).not_to include(user.default_pseud)
        end
      end
    end
  end

  describe "#moderator_changes=" do
    context "when assigning a user that is not a moderator" do
      it "makes the user a moderator" do
        owned_tag_set.update(moderator_changes: user.login)
        expect(owned_tag_set.moderators.reload).to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "makes the first user a moderator" do
          owned_tag_set.update(moderator_changes: user.login)
          expect(owned_tag_set.moderators.reload).to include(user.default_pseud)
        end
      end
    end

    context "when assigning a user that is a moderator" do
      before do
        owned_tag_set.add_moderator(user.default_pseud)
        owned_tag_set.save
        owned_tag_set.reload
      end

      it "removes the user as a moderator" do
        owned_tag_set.update(moderator_changes: user.login)
        expect(owned_tag_set.moderators.reload).not_to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "removes the first user as a moderator" do
          owned_tag_set.update(moderator_changes: user.login)
          expect(owned_tag_set.moderators.reload).not_to include(user.default_pseud)
        end
      end
    end
  end
end
