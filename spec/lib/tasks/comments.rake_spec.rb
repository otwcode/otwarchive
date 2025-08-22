# frozen_string_literal: true

require "spec_helper"

describe "rake comment:sync_approved_to_spam" do
  let(:synced_ham_comment) { create(:comment) }
  let(:synced_spam_comment) { create(:comment) }
  let(:unsynced_ham_comment) { create(:comment) }
  let(:unsynced_spam_comment) { create(:comment) }
  # Adding a second unsynced spam to ensure more than a single approved: false, spam: false is processed correctly.
  let(:unsynced_spam_comment_two) { create(:comment, approved: false, spam: false) }

  before do
    # Setup comment states. This is required because approved is set on comment creation via lifecycle hook.
    synced_ham_comment.update_columns(approved: true, spam: false)
    synced_spam_comment.update_columns(approved: false, spam: true)
    unsynced_ham_comment.update_columns(approved: true, spam: true)
    unsynced_spam_comment.update_columns(approved: false, spam: false)
    unsynced_spam_comment_two.update_columns(approved: false, spam: false)
  end

  context "when running across entire Comment collection" do
    it "updates spam attribute for all unsynced comments" do
      subject.invoke

      [unsynced_ham_comment, unsynced_spam_comment, unsynced_spam_comment_two].map(&:reload)

      expect(unsynced_ham_comment.approved).to be_truthy
      expect(unsynced_ham_comment.spam).to be_falsey

      expect(unsynced_spam_comment.approved).to be_falsey
      expect(unsynced_spam_comment.spam).to be_truthy

      expect(unsynced_spam_comment_two.approved).to be_falsey
      expect(unsynced_spam_comment_two.spam).to be_truthy
    end

    it "does not update synced comments" do
      subject.invoke

      [synced_ham_comment, synced_spam_comment].map(&:reload)

      expect(synced_ham_comment.approved).to be_truthy
      expect(synced_ham_comment.spam).to be_falsey

      expect(synced_spam_comment.approved).to be_falsey
      expect(synced_spam_comment.spam).to be_truthy
    end
  end

  context "when limiting to a subset of Comment collection" do
    let(:limit) { 2 }

    it "only updates the specified limit of records" do
      initial_unsynced_comment_count = Comment.where("(approved IS TRUE AND spam IS TRUE) OR (approved IS FALSE AND spam IS FALSE)").count

      subject.invoke(limit.to_s)

      unsynced_comment_count = Comment.where("(approved IS TRUE AND spam IS TRUE) OR (approved IS FALSE AND spam IS FALSE)").count
      expect(initial_unsynced_comment_count - unsynced_comment_count).to be limit
    end
  end
end
