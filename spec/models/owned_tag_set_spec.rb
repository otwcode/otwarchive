# frozen_string_literal: true

require "spec_helper"

describe OwnedTagSet do
  let(:owned_tag_set) { create(:owned_tag_set) }
  let(:user) { create(:user) }

  describe "#owner_changes=" do
    context "given a user that is not an owner" do
      it "makes the user an owner when assigning their login" do
        owned_tag_set.update!(owner_changes: user.login)
        expect(owned_tag_set.owners.reload).to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "makes the first user an owner when assigning their login" do
          owned_tag_set.update!(owner_changes: user.login)
          expect(owned_tag_set.owners.reload).to include(user.default_pseud)
          expect(owned_tag_set.owners.reload).not_to include(other_pseud)
        end

        it "makes the second user an owner when assigning the full byline for the other user's pseud" do
          owned_tag_set.update!(owner_changes: "#{other_pseud.name} (#{other_pseud.user.login})")
          expect(owned_tag_set.owners.reload).not_to include(user.default_pseud)
          expect(owned_tag_set.owners.reload).to include(other_pseud)
        end
      end
    end

    context "given a user that is a co-owner" do
      before do
        owned_tag_set.add_owner(user.default_pseud)
        owned_tag_set.save
        owned_tag_set.reload
      end

      it "removes the user as an owner when assigning their login" do
        owned_tag_set.update!(owner_changes: user.login)
        expect(owned_tag_set.owners.reload).not_to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name who is also a co-owner" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        before do
          owned_tag_set.add_owner(other_pseud)
          owned_tag_set.save
          owned_tag_set.reload
        end

        it "removes the first user as an owner when assigning their login" do
          owned_tag_set.update!(owner_changes: user.login)
          expect(owned_tag_set.owners.reload).not_to include(user.default_pseud)
          expect(owned_tag_set.owners.reload).to include(other_pseud)
        end

        it "removes the second user an owner when assigning the full byline for the other user's pseud" do
          owned_tag_set.update!(owner_changes: "#{other_pseud.name} (#{other_pseud.user.login})")
          expect(owned_tag_set.owners.reload).to include(user.default_pseud)
          expect(owned_tag_set.owners.reload).not_to include(other_pseud)
        end
      end
    end
  end

  describe "#moderator_changes=" do
    context "given a user that is not a moderator" do
      it "makes the user a moderator when assigning their login" do
        owned_tag_set.update!(moderator_changes: user.login)
        expect(owned_tag_set.moderators.reload).to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        it "makes the first user a moderator when assigning their login" do
          owned_tag_set.update!(moderator_changes: user.login)
          expect(owned_tag_set.moderators.reload).to include(user.default_pseud)
          expect(owned_tag_set.moderators.reload).not_to include(other_pseud)
        end

        it "makes the second user a moderator when assigning the full byline for the other user's pseud" do
          owned_tag_set.update!(moderator_changes: "#{other_pseud.name} (#{other_pseud.user.login})")
          expect(owned_tag_set.moderators.reload).not_to include(user.default_pseud)
          expect(owned_tag_set.moderators.reload).to include(other_pseud)
        end
      end
    end

    context "given a user that is a moderator" do
      before do
        owned_tag_set.add_moderator(user.default_pseud)
        owned_tag_set.save
        owned_tag_set.reload
      end

      it "removes the user as a moderator when assigning their login" do
        owned_tag_set.update!(moderator_changes: user.login)
        expect(owned_tag_set.moderators.reload).not_to include(user.default_pseud)
      end

      context "when there is another user with a pseud of the same name who is also a moderator" do
        let!(:other_pseud) { create(:pseud, name: user.login) }

        before do
          owned_tag_set.add_moderator(other_pseud)
          owned_tag_set.save
          owned_tag_set.reload
        end

        it "removes the first user as a moderator when assigning their login" do
          owned_tag_set.update!(moderator_changes: user.login)
          expect(owned_tag_set.moderators.reload).not_to include(user.default_pseud)
          expect(owned_tag_set.moderators.reload).to include(other_pseud)
        end

        it "removes the second user a moderator when assigning the full byline for the other user's pseud" do
          owned_tag_set.update!(moderator_changes: "#{other_pseud.name} (#{other_pseud.user.login})")
          expect(owned_tag_set.moderators.reload).to include(user.default_pseud)
          expect(owned_tag_set.moderators.reload).not_to include(other_pseud)
        end
      end
    end
  end
end
