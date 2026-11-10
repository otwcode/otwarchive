require "spec_helper"

describe Users::DeleteAccount do
  let!(:user) { create(:user) }
  let(:pseud) { user.default_pseud }

  context "for a user with no creations" do
    it "deletes the account" do
      Users::DeleteAccount.new(user).call
      expect { user.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "for a user with co-authored works" do
    let!(:coauthor) { create(:pseud) }
    let!(:work) { create(:work, authors: [pseud, coauthor]) }

    context "who chooses orphaning" do
      let!(:orphan_account) { create(:user, login: "orphan_account") }

      it "transfers the creatorship to the orphan account" do
        prefs = { coauthor: "orphan_pseud", use_default: true }
        Users::DeleteAccount.new(user, preferences: prefs).call
        work.reload
        expect(work.pseuds).to match_array([orphan_account.default_pseud, coauthor])
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
      it "creates a new orphan account pseud if use_default is false" do
        name = pseud.name
        prefs = { coauthor: "keep_pseud", use_default: false }
        Users::DeleteAccount.new(user, preferences: prefs).call
        work.reload
        new_orphan_pseud = orphan_account.pseuds.find_by!(name: name)
        expect(work.pseuds).to match_array([new_orphan_pseud, coauthor])
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    context "who chooses removal" do
      it "deletes the creatorship" do
        prefs = { coauthor: "remove" }
        Users::DeleteAccount.new(user, preferences: prefs).call
        work.reload
        expect(work.pseuds).to contain_exactly(coauthor)
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    context "who supplies an invalid option" do
      it "raises an error" do
        prefs = { coauthor: "foo" }
        expect do
          Users::DeleteAccount.new(user, preferences: prefs).call
        end.to raise_exception(Users::DeleteAccount::DeleteFailed, "Unknown preference 'foo'")
      end
    end
  end

  context "for a user with sole-authored works" do
    let!(:work) { create(:work, authors: [pseud]) }

    context "who chooses orphaning" do
      let!(:orphan_account) { create(:user, login: "orphan_account") }

      it "transfers the works to the orphan account" do
        prefs = { sole_author: "orphan_pseud", use_default: true }
        Users::DeleteAccount.new(user, preferences: prefs).call
        work.reload
        expect(work.pseuds).to contain_exactly(orphan_account.default_pseud)
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
      it "creates a new orphan account pseud if use_default is false" do
        name = pseud.name
        prefs = { sole_author: "keep_pseud", use_default: false }
        Users::DeleteAccount.new(user, preferences: prefs).call
        work.reload
        new_orphan_pseud = orphan_account.pseuds.find_by!(name: name)
        expect(work.pseuds).to contain_exactly(new_orphan_pseud)
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    context "who chooses deletion" do
      it "deletes the works" do
        expect(user.works.count).to eq(1)
        Users::DeleteAccount.new(user, preferences: { sole_author: "delete" }).call
        expect { work.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
        expect { user.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    context "who supplies an invalid option" do
      it "raises an error" do
        prefs = { sole_author: "foo" }
        expect do
          Users::DeleteAccount.new(user, preferences: prefs).call
        end.to raise_exception(Users::DeleteAccount::DeleteFailed, "Unknown preference 'foo'")
      end
    end
  end

  context "for a user with sole-owned collections" do
    let!(:collection) { create(:collection, owner: pseud) }

    context "who chooses orphaning" do
      let!(:orphan_account) { create(:user, login: "orphan_account") }

      it "transfers the collection to the orphan account" do
        prefs = { sole_author: "orphan_pseud", use_default: true }
        Users::DeleteAccount.new(user, preferences: prefs).call
        collection.reload
        expect(collection.owners).to contain_exactly(orphan_account.default_pseud)
      end
      it "creates a new orphan account pseud if use_default is false" do
        name = pseud.name
        prefs = { sole_author: "keep_pseud", use_default: false }
        Users::DeleteAccount.new(user, preferences: prefs).call
        collection.reload
        new_orphan_pseud = orphan_account.pseuds.find_by!(name: name)
        collection.reload
        expect(collection.owners).to contain_exactly(new_orphan_pseud)
      end
    end
    context "who chooses deletion" do
      it "deletes the collection" do
        Users::DeleteAccount.new(user, preferences: { sole_author: "delete" }).call
        expect { collection.reload }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "finish_cleanup" do
    it "removes empty series" do
      series = create(:series, authors: [pseud])
      Users::DeleteAccount.new(user, preferences: { sole_author: "delete" }).call
      expect { series.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "does not delete a series with someone else's works in it" do
      coauthor = create(:pseud)
      series = create(:series, authors: [coauthor])
      work = create(:work, authors: [pseud])
      series.works << work
      Users::DeleteAccount.new(user, preferences: { sole_author: "delete" }).call
      series.reload
      expect(series.pseuds).to contain_exactly(coauthor)
    end

    it "removes unposted drafts" do
      draft = create(:draft, authors: [pseud])
      Users::DeleteAccount.new(user).call
      expect { draft.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "removes stray chapters" do
      work = create(:work, authors: [pseud])
      chapter = work.chapters.first
      chapter.update_column(:work_id, nil)
      work.delete
      Users::DeleteAccount.new(user, preferences: { sole_author: "delete" }).call
      expect { chapter.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "does not delete stray chapters with co-authors" do
      coauthor = create(:pseud)
      work = create(:work, authors: [pseud, coauthor])
      chapter = work.chapters.first
      chapter.update_column(:work_id, nil)
      work.delete
      Users::DeleteAccount.new(user, preferences: { coauthor: "remove" }).call
      expect(chapter.reload.pseuds).to contain_exactly(coauthor)
    end
  end
end
