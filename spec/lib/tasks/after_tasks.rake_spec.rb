require "spec_helper"

describe "rake After:add_default_rating_to_works" do
  context "for a work missing rating" do
    let!(:unrated_work) do
      work = create(:work)
      work.ratings = []
      work.save!(validate: false)
      return work
    end

    it "sets default rating on work which is missing a rating" do
      subject.invoke
      unrated_work.reload
      expect(unrated_work.rating_string).to eq(ArchiveConfig.RATING_DEFAULT_TAG_NAME)
    end
  end

  context "for a rated work" do
    let!(:work) { create(:work, rating_string: ArchiveConfig.RATING_EXPLICIT_TAG_NAME) }

    it "does not modify works which already have a rating" do
      subject.invoke
      work.reload
      expect(work.rating_string).to eq(ArchiveConfig.RATING_EXPLICIT_TAG_NAME)
    end
  end
end

describe "rake After:fix_teen_and_up_imported_rating" do
  let!(:noncanonical_teen_rating) do
    tag = Rating.create(name: "Teen & Up Audiences")
    tag.canonical = false
    tag.save!(validate: false)
    return tag
  end
  let!(:canonical_gen_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_GENERAL_TAG_NAME, canonical: true) }
  let!(:canonical_teen_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME, canonical: true) }
  let!(:work_with_noncanonical_rating) { create(:work, rating_string: noncanonical_teen_rating.name) }
  let!(:work_with_canonical_and_noncanonical_ratings) { create_invalid(:work, rating_string: [noncanonical_teen_rating.name, ArchiveConfig.RATING_GENERAL_TAG_NAME].join(",")) }

  it "updates the works' ratings to the canonical teen rating" do
    subject.invoke
    expect(work_with_noncanonical_rating.reload.ratings.to_a).to contain_exactly(canonical_teen_rating)
    expect(work_with_canonical_and_noncanonical_ratings.reload.ratings.to_a).to contain_exactly(canonical_teen_rating, canonical_gen_rating)
  end
end

describe "rake After:clean_up_multiple_ratings" do
  let!(:default_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME, canonical: true) }
  let!(:other_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME, canonical: true) }
  let!(:work_with_multiple_ratings) do
    create_invalid(:work, rating_string: [default_rating.name, other_rating.name].join(",")).tap do |work|
      # Update the creatorship to a user so validation doesn't fail
      work.creatorships.build(pseud: build(:pseud), approved: true)
      work.save!(validate: false)
    end
  end

  before do
    run_all_indexing_jobs
  end

  it "changes and replaces the multiple tags" do
    subject.invoke

    work_with_multiple_ratings.reload

    # Work with multiple ratings gets the default rating
    expect(work_with_multiple_ratings.ratings.to_a).to contain_exactly(default_rating)
    expect(work_with_multiple_ratings.rating_string).to eq(default_rating.name)
  end
end

describe "rake After:clean_up_noncanonical_ratings" do
  let!(:noncanonical_rating) do
    tag = Rating.create(name: "Borked rating tag", canonical: false)
    tag.save!(validate: false)
    tag
  end
  let!(:canonical_teen_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME, canonical: true) }
  let!(:default_rating) { Rating.find_or_create_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME, canonical: true) }
  let!(:work_with_noncanonical_rating) { create(:work, rating_string: noncanonical_rating.name) }
  let!(:work_with_canonical_and_noncanonical_ratings) { create_invalid(:work, rating_string: [noncanonical_rating.name, canonical_teen_rating.name]) }

  it "changes and replaces the noncanonical rating tags" do
    subject.invoke

    work_with_noncanonical_rating.reload
    work_with_canonical_and_noncanonical_ratings.reload

    # Changes the noncanonical ratings into freeforms
    noncanonical_rating = Tag.find_by(name: "Borked rating tag")
    expect(noncanonical_rating).to be_a(Freeform)
    expect(work_with_noncanonical_rating.freeforms.to_a).to contain_exactly(noncanonical_rating)
    expect(work_with_canonical_and_noncanonical_ratings.freeforms.to_a).to contain_exactly(noncanonical_rating)

    # Adds the default rating to works left without any other rating
    expect(work_with_noncanonical_rating.ratings.to_a).to contain_exactly(default_rating)

    # Doesn't add the default rating to works that have other ratings
    expect(work_with_canonical_and_noncanonical_ratings.ratings.to_a).to contain_exactly(canonical_teen_rating)
  end
end

describe "rake After:clean_up_noncanonical_categories" do
  let!(:canonical_category_tag) { Category.find_or_create_by(name: ArchiveConfig.CATEGORY_GEN_TAG_NAME, canonical: true) }
  let!(:noncanonical_category_tag) do
    tag = Category.create(name: "Borked category tag")
    tag.canonical = false
    tag.save!(validate: false)
    return tag
  end
  let!(:work_with_noncanonical_categ) do
    work = create(:work)
    work.categories = [noncanonical_category_tag]
    work.save!(validate: false)
    return work
  end
  let!(:work_with_canonical_and_noncanonical_categs) do
    work = create(:work)
    work.categories = [noncanonical_category_tag, canonical_category_tag]
    work.save!(validate: false)
    return work
  end

  it "changes and replaces the noncanonical category tags" do
    subject.invoke
    work_with_noncanonical_categ.reload
    work_with_canonical_and_noncanonical_categs.reload

    # Changes the noncanonical categories into freeforms
    noncanonical_category_tag = Tag.find_by(name: "Borked category tag")
    expect(noncanonical_category_tag).to be_a(Freeform)
    expect(work_with_noncanonical_categ.freeforms.to_a).to include(noncanonical_category_tag)
    expect(work_with_canonical_and_noncanonical_categs.freeforms.to_a).to include(noncanonical_category_tag)

    # Leaves the works that had no other categories without a category
    expect(work_with_noncanonical_categ.categories.to_a).to be_empty

    # Leaves the works that had other categories with those categories
    expect(work_with_canonical_and_noncanonical_categs.categories.to_a).to contain_exactly(canonical_category_tag)
  end
end

describe "rake After:fix_tags_with_extra_spaces" do
  let(:borked_tag) { Freeform.create(name: "whatever") }

  it "replaces the spaces with the same number of underscores" do
    borked_tag.update_column(:name, "\u00A0\u2002\u2003\u202F\u205FBorked\u00A0\u2002\u2003\u202Ftag\u00A0\u2002\u2003\u202F\u205F")
    subject.invoke

    borked_tag.reload
    expect(borked_tag.name).to eql("_____Borked____tag_____")
  end

  it "handles duplicated names" do
    Freeform.create(name: "Borked_tag")
    borked_tag.update_column(:name, "Borked\u00A0tag")
    subject.invoke

    borked_tag.reload
    expect(borked_tag.name).to eql("Borked_tag_")
  end

  it "handles tags with quotes" do
    borked_tag.update_column(:name, "\u00A0\"'quotes'\"")
    expect do
      subject.invoke
    end.to output(/.*Tag ID,Old tag name,New tag name\n#{borked_tag.id},\"\u00A0\"\"'quotes'\"\"\",\"_\"\"'quotes'\"\"\"\n$/).to_stdout

    borked_tag.reload
    expect(borked_tag.name).to eql("_\"'quotes'\"")
  end
end

describe "rake After:fix_2009_comment_threads" do
  before { Comment.delete_all }

  let(:comment) { create(:comment, id: 13) }
  let(:reply) { create(:comment, commentable: comment) }

  context "when a comment has the correct thread set" do
    it "doesn't change the thread" do
      expect do
        subject.invoke
      end.to output("Updating 0 thread(s)\n").to_stdout
        .and avoid_changing { comment.reload.thread }
        .and avoid_changing { reply.reload.thread }
    end
  end

  context "when a comment has an incorrect thread set" do
    before { comment.update_column(:thread, 1) }

    it "fixes the threads" do
      expect do
        subject.invoke
      end.to output("Updating 1 thread(s)\n").to_stdout
        .and change { comment.reload.thread }.from(1).to(13)
        .and change { reply.reload.thread }.from(1).to(13)
    end

    context "when the comment has many replies" do
      it "fixes the threads for all of them" do
        replies = create_list(:comment, 10, commentable: comment)

        expect do
          subject.invoke
        end.to output("Updating 1 thread(s)\n").to_stdout
          .and change { comment.reload.thread }.from(1).to(13)

        replies.each do |reply|
          expect { reply.reload }.to change { reply.thread }.from(1).to(13)
        end
      end
    end

    context "when the comment has deeply nested replies" do
      it "fixes the threads for all of them" do
        replies = [reply]

        10.times { replies << create(:comment, commentable: replies.last) }

        expect do
          subject.invoke
        end.to output("Updating 1 thread(s)\n").to_stdout
          .and change { comment.reload.thread }.from(1).to(13)

        replies.each do |reply|
          expect { reply.reload }.to change { reply.thread }.from(1).to(13)
        end
      end
    end
  end
end

describe "rake After:remove_translation_admin_role" do
  it "remove translation admin role" do
    user = create(:user)
    user.roles = [Role.create(name: "translation_admin")]
    subject.invoke
    expect(Role.all).to be_empty
    expect(user.reload.roles).to be_empty
  end
end

describe "rake After:remove_invalid_commas_from_tags" do
  let(:prompt) { "Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:\n" }
  let!(:chinese_tag) do
    tag = create(:tag)
    tag.update_column(:name, "Full-width，Comma")
    tag
  end
  let!(:japanese_tag) do
    tag = create(:tag)
    tag.update_column(:name, "Ideographic、Comma")
    tag
  end

  it "puts an error and does not rename tags without a valid admin" do
    allow($stdin).to receive(:gets) { "typo" }

    expect do
      subject.invoke
    end.to avoid_changing { chinese_tag.reload.name }
      .and avoid_changing { japanese_tag.reload.name }
      .and output("#{prompt}Admin not found.\n").to_stdout
  end

  context "with a valid admin" do
    let!(:admin) { create(:admin, login: "admin") }

    before do
      allow($stdin).to receive(:gets) { "admin" }
    end

    it "removes full-width and ideographic commas when the name is otherwise unique" do
      expect do
        subject.invoke
      end.to change { chinese_tag.reload.name }
        .from("Full-width，Comma")
        .to("Full-widthComma")
        .and change { japanese_tag.reload.name }
        .from("Ideographic、Comma")
        .to("IdeographicComma")
        .and output("#{prompt}Full-widthComma\nIdeographicComma\n").to_stdout
    end

    it "removes full-width and ideographic commas and appends \" - AO3-6626\" when the name is not unique" do
      create(:tag, name: "Full-widthComma")
      create(:tag, name: "IdeographicComma")

      expect do
        subject.invoke
      end.to change { chinese_tag.reload.name }
        .from("Full-width，Comma")
        .to("Full-widthComma - AO3-6626")
        .and change { japanese_tag.reload.name }
        .from("Ideographic、Comma")
        .to("IdeographicComma - AO3-6626")
        .and output("#{prompt}Full-widthComma - AO3-6626\nIdeographicComma - AO3-6626\n").to_stdout
    end

    it "puts an error when the tag cannot be renamed" do
      allow_any_instance_of(Tag).to receive(:save).and_return(false)

      expect do
        subject.invoke
      end.to avoid_changing { chinese_tag.reload.name }
        .and avoid_changing { japanese_tag.reload.name }
        .and output("#{prompt}Could not rename Full-width，Comma\nCould not rename Ideographic、Comma\n").to_stdout
    end
  end
end

describe "rake After:add_suffix_to_underage_sex_tag" do
  let(:prompt) { "Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:\n" }

  context "without a valid admin" do
    it "puts an error without a valid admin" do
      allow($stdin).to receive(:gets) { "no-admin" }

      expect do
        subject.invoke
      end.to output("#{prompt}Admin not found.\n").to_stdout
    end
  end

  context "with a valid admin" do
    let!(:admin) { create(:admin, login: "admin") }

    before do
      allow($stdin).to receive(:gets) { "admin" }
      tag = ArchiveWarning.find_by_name("Underage Sex")
      tag.destroy!
    end

    it "puts an error if tag does not exist" do
      expect do
        subject.invoke
      end.to output("#{prompt}No Underage Sex tag found.\n").to_stdout
    end

    it "puts an error if tag is an ArchiveWarning" do
      tag = create(:archive_warning, name: "Underage Sex")

      expect do
        subject.invoke
      end.to avoid_changing { tag.reload.name }
        .and output("#{prompt}Underage Sex is already an Archive Warning.\n").to_stdout
    end

    it "puts a success message if tag exists and can be renamed" do
      tag = create(:relationship, name: "Underage Sex")

      expect do
        subject.invoke
      end.to change { tag.reload.name }
        .from("Underage Sex")
        .to("Underage Sex - Relationship")
        .and output("#{prompt}Renamed Underage Sex tag to Underage Sex - Relationship.\n").to_stdout
    end

    it "puts an error if tag exists and cannot be renamed" do
      tag = create(:freeform, name: "Underage Sex")
      allow_any_instance_of(Tag).to receive(:save).and_return(false)

      expect do
        subject.invoke
      end.to avoid_changing { tag.reload.name }
        .and output("#{prompt}Failed to rename Underage Sex tag to Underage Sex - Freeform.\n").to_stdout
    end
  end
end

describe "rake After:rename_underage_warning" do
  let(:prompt) { "Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:\n" }

  context "without a valid admin" do
    it "puts an error without a valid admin" do
      allow($stdin).to receive(:gets) { "no-admin" }

      expect do
        subject.invoke
      end.to output("#{prompt}Admin not found.\n").to_stdout
    end
  end

  context "with a valid admin" do
    let!(:admin) { create(:admin, login: "admin") }

    before do
      allow($stdin).to receive(:gets) { "admin" }
      tag = ArchiveWarning.find_by_name("Underage Sex")
      tag.destroy!
    end

    it "puts an error if tag does not exist" do
      expect do
        subject.invoke
      end.to output("#{prompt}No Underage warning tag found.\n").to_stdout
    end

    it "puts a success message if tag exists and can be renamed" do
      tag = create(:archive_warning, name: "Underage")

      expect do
        subject.invoke
      end.to change { tag.reload.name }
        .from("Underage")
        .to("Underage Sex")
        .and output("#{prompt}Renamed Underage warning tag to Underage Sex.\n").to_stdout
    end

    it "puts an error if tag exists and cannot be renamed" do
      tag = create(:archive_warning, name: "Underage")
      allow_any_instance_of(Tag).to receive(:save).and_return(false)

      expect do
        subject.invoke
      end.to avoid_changing { tag.reload.name }
        .and output("#{prompt}Failed to rename Underage warning tag to Underage Sex.\n").to_stdout
    end
  end
end

describe "rake After:migrate_pinch_request_signup" do
  context "for an assignment with a request_signup_id" do
    let(:assignment) { create(:challenge_assignment) }

    it "does nothing" do
      expect do
        subject.invoke
      end.to avoid_changing { assignment.reload.request_signup_id }
        .and output("Migrated pinch_request_signup for 0 challenge assignments.\n").to_stdout
    end
  end

  context "for an assignment with a request_signup_id and a pinch_request_signup_id" do
    let(:collection) { create(:collection) }
    let(:assignment) do
      create(:challenge_assignment,
             collection: collection,
             pinch_request_signup_id: create(:challenge_signup, collection: collection).id)
    end

    it "does nothing" do
      expect do
        subject.invoke
      end.to avoid_changing { assignment.reload.request_signup_id }
        .and output("Migrated pinch_request_signup for 0 challenge assignments.\n").to_stdout
    end
  end

  context "for an assignment with a pinch_request_signup_id but no request_signup_id" do
    let(:collection) { create(:collection) }
    let(:signup) { create(:challenge_signup, collection: collection) }
    let(:assignment) do
      assignment = create(:challenge_assignment, collection: collection)
      assignment.update_columns(request_signup_id: nil, pinch_request_signup_id: signup.id)
      assignment
    end

    it "sets the request_signup_id to the pinch_request_signup_id" do
      expect do
        subject.invoke
      end.to change { assignment.reload.request_signup_id }
        .from(nil)
        .to(signup.id)
        .and output("Migrated pinch_request_signup for 1 challenge assignments.\n").to_stdout
    end
  end
end

describe "rake After:reindex_hidden_unrevealed_tags" do
  context "with a posted work" do
    let!(:work) { create(:work) }

    it "does not reindex the work's tags" do
      expect do
        subject.invoke
      end.not_to add_to_reindex_queue(work.tags.first, :main)
    end
  end

  context "with a hidden work" do
    let!(:work) { create(:work, hidden_by_admin: true) }

    it "reindexes the work's tags" do
      expect do
        subject.invoke
      end.to add_to_reindex_queue(work.tags.first, :main)
    end
  end

  context "with an unrevealed work" do
    let(:work) { create(:work) }

    before do
      work.update!(in_unrevealed_collection: true)
    end

    it "reindexes the work's tags" do
      expect do
        subject.invoke
      end.to add_to_reindex_queue(work.tags.first, :main)
    end
  end
end

describe "rake After:convert_official_kudos" do
  context "when there is no official role" do
    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("No official users found\n").to_stdout
    end
  end

  context "when there are no official users" do
    let!(:role) { Role.find_or_create_by(name: "official") }

    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("No official users found\n").to_stdout
    end
  end

  context "when there are official users but none have left kudos" do
    let!(:official_user) { create(:official_user) }

    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("Finished converting kudos from official users to guest kudos\n").to_stdout
    end
  end

  context "when an official user and a regular user both have kudos" do
    let!(:official_user1) { create(:user) }
    let!(:official_kudos1) { create(:kudo, user: official_user1) }
    let!(:regular_user) { create(:user) }
    let!(:regular_kudos) { create(:kudo, user: regular_user) }

    before do
      official_user1.roles = [Role.find_or_create_by(name: "official")]
    end

    it "removes the user_id from the official user's kudos and outputs completion message" do
      expect do
        subject.invoke
      end.to change { official_kudos1.reload.user_id }
        .from(official_user1.id)
        .to(nil)
        .and output("Updating 1 kudos from #{official_user1.login}\nFinished converting kudos from official users to guest kudos\n").to_stdout
    end

    it "leaves the user_id on the regular user's kudos and outputs completion message" do
      expect do
        subject.invoke
      end.to avoid_changing { regular_kudos.reload.user_id }
        .and output("Updating 1 kudos from #{official_user1.login}\nFinished converting kudos from official users to guest kudos\n").to_stdout
    end
  end
end

describe "rake After:convert_archivist_kudos" do
  context "when there is no archivist role" do
    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("No archivist users found\n").to_stdout
    end
  end

  context "when there are no archivist users" do
    let!(:role) { Role.find_or_create_by(name: "archivist") }

    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("No archivist users found\n").to_stdout
    end
  end

  context "when there are archivist users but none have left kudos" do
    let!(:archivist_user) { create(:archivist) }

    it "outputs completion message" do
      expect do
        subject.invoke
      end.to output("Finished converting kudos from archivist users to guest kudos\n").to_stdout
    end
  end

  context "when an archivist user and a regular user both have kudos" do
    let!(:archivist_user1) { create(:user) }
    let!(:archivist_kudos1) { create(:kudo, user: archivist_user1) }
    let!(:regular_user) { create(:user) }
    let!(:regular_kudos) { create(:kudo, user: regular_user) }

    before do
      archivist_user1.roles = [Role.find_or_create_by(name: "archivist")]
    end

    it "removes the user_id from the archivist user's kudos and outputs completion message" do
      expect do
        subject.invoke
      end.to change { archivist_kudos1.reload.user_id }
        .from(archivist_user1.id)
        .to(nil)
        .and output("Updating 1 kudos from #{archivist_user1.login}\nFinished converting kudos from archivist users to guest kudos\n").to_stdout
    end

    it "leaves the user_id on the regular user's kudos and outputs completion message" do
      expect do
        subject.invoke
      end.to avoid_changing { regular_kudos.reload.user_id }
        .and output("Updating 1 kudos from #{archivist_user1.login}\nFinished converting kudos from archivist users to guest kudos\n").to_stdout
    end
  end
end

describe "rake After:create_non_canonical_tagset_associations" do
  shared_examples "no TagSetAssociation is created" do
    it "does not create a TagSetAssociation" do
      expect do
        subject.invoke
      end.to avoid_changing { TagSetAssociation.count }
    end
  end

  context "when a tag is already canonical" do
    let!(:character) { create(:canonical_character) }
    let!(:relationship) { create(:canonical_relationship) }
    let!(:owned_tag_set) { create(:owned_tag_set, tags: [character, relationship]) }

    it_behaves_like "no TagSetAssociation is created"
  end

  context "when a canonical tag belongs to a canonical fandom" do
    let!(:character) { create(:common_tagging, common_tag: create(:canonical_character)).common_tag }
    let!(:relationship) { create(:common_tagging, common_tag: create(:canonical_relationship)).common_tag }
    let!(:owned_tag_set) { create(:owned_tag_set, tags: [character, relationship]) }

    it_behaves_like "no TagSetAssociation is created"
  end

  context "when a non-canonical tag belongs to a canonical fandom" do
    let!(:character) { create(:common_tagging, common_tag: create(:character)).common_tag }
    let!(:relationship) { create(:common_tagging).common_tag }

    context "when the fandom does not belong to the TagSet" do
      let!(:owned_tag_set) { create(:owned_tag_set, tags: [character, relationship]) }

      it_behaves_like "no TagSetAssociation is created"
    end

    context "when the fandom belongs to the TagSet" do
      let!(:owned_tag_set) do
        create(:owned_tag_set, tags: [character, character.fandoms, relationship, relationship.fandoms].flatten)
      end

      it "creates a TagSetAssociation for each tag" do
        subject.invoke
        expect(TagSetAssociation.where(tag: character, owned_tag_set: owned_tag_set)).to exist
        expect(TagSetAssociation.where(tag: relationship, owned_tag_set: owned_tag_set)).to exist
      end
    end

    context "when a TagSetAssociation already exists for the fandom and tag" do
      let!(:owned_tag_set) do
        create(:owned_tag_set, tags: [character, character.fandoms, relationship, relationship.fandoms].flatten)
      end

      before do
        create(:tag_set_association,
               owned_tag_set: owned_tag_set, tag: character, parent_tag: character.fandoms.first)
        create(:tag_set_association,
               owned_tag_set: owned_tag_set, tag: relationship, parent_tag: relationship.fandoms.first)
      end

      it_behaves_like "no TagSetAssociation is created"
    end
  end
end

describe "rake After:add_collection_tags" do
  let(:collection) { create(:collection) }
  let(:items) { [] }

  before do
    items.each do |item|
      item.collections << collection
      item.collection_items.update_all(
        user_approval_status: "approved",
        collection_approval_status: "approved"
      )
    end
  end

  context "when a collection has works" do
    let(:items) { create_list(:work, 2) }

    it "tags the collection with the work's fandoms" do
      subject.invoke
      expect(collection.tags).to include(*items.flat_map(&:fandoms))
    end

    shared_examples "does not tag the collection" do
      it "does not tag the collection with the work's fandoms" do
        subject.invoke
        expect(collection.tags).not_to include(*items.flat_map(&:fandoms))
      end
    end

    context "when the work is hidden" do
      let(:items) { [create(:work, hidden_by_admin: true)] }

      it_behaves_like "does not tag the collection"
    end

    context "when the work is restricted" do
      let(:items) { [create(:work, restricted: true)] }

      it_behaves_like "does not tag the collection"
    end

    context "when the work is unrevealed" do
      let(:items) { [create(:work)] }

      before do
        items.each do |work|
          work.update!(in_unrevealed_collection: true)
        end
      end

      it_behaves_like "does not tag the collection"
    end
  end

  context "when a collection has work bookmarks" do
    let(:fandom) { create(:canonical_fandom) }
    let(:items) { [create(:bookmark, tag_string: fandom.name)] }

    it "tags the collection with the bookmark's AND bookmarked item's fandoms" do
      subject.invoke
      expect(collection.tags).to include(*items.flat_map(&:fandoms))
      expect(collection.tags).to include(*items.flat_map(&:bookmarkable).flat_map(&:fandoms))
    end

    shared_examples "does not tag the collection" do
      it "does not tag the collection with the bookmark's or bookmarked item's fandoms" do
        subject.invoke
        expect(collection.tags).not_to include(*items.flat_map(&:fandoms))
        expect(collection.tags).not_to include(*items.flat_map(&:bookmarkable).flat_map(&:fandoms))
      end
    end

    context "when the bookmarked item is a hidden work" do
      before do
        items.each do |bookmark|
          bookmark.bookmarkable.update!(hidden_by_admin: true)
        end
      end

      it_behaves_like "does not tag the collection"
    end

    context "when the bookmarked item is a restricted work" do
      before do
        items.each do |bookmark|
          bookmark.bookmarkable.update!(restricted: true)
        end
      end

      it_behaves_like "does not tag the collection"
    end

    context "when the bookmarked item is an unrevealed work" do
      before do
        items.each do |bookmark|
          bookmark.bookmarkable.update!(in_unrevealed_collection: true)
        end
      end

      it_behaves_like "does not tag the collection"
    end
  end

  context "when a collection has a series bookmark" do
    let(:fandom) { create(:canonical_fandom) }
    let(:bookmark) { create(:series_bookmark, tag_string: fandom.name) }
    let(:items) { [bookmark] }

    it "includes the bookmark's and series's fandoms" do
      subject.invoke
      expect(collection.tags).to include(*bookmark.fandoms)
      expect(collection.tags).to include(*items.flat_map(&:bookmarkable).flat_map { |s| s.work_tags.where(type: "Fandom") })
    end
  end

  context "when a collection has a subcollection" do
    let(:subcollection) { create(:collection) }
    let(:fandom) { create(:canonical_fandom) }
    let(:bookmark) { create(:series_bookmark, fandom_string: fandom.name) }

    before do
      subcollection.parent = collection
      subcollection.save!(validate: false)
      bookmark.collections << subcollection
      bookmark.collection_items.update_all(
        user_approval_status: "approved",
        collection_approval_status: "approved"
      )
    end

    it "includes tags from the items in the subcollection" do
      subject.invoke
      expect(collection.reload.tags).to include(*bookmark.fandoms)
    end
  end
end

describe "rake After:sync_approved_to_spam" do
  let(:synced_ham_comment) { create(:comment) }
  let(:synced_spam_comment) { create(:comment) }
  let(:unsynced_ham_comment) { create(:comment) }
  let(:unsynced_spam_comment) { create(:comment) }
  # Adding a second unsynced spam to ensure more than a single approved: false, spam: false is processed correctly.
  let(:unsynced_spam_comment_two) { create(:comment) }

  before do
    # Setup comment states. This is required because approved is set on comment creation via lifecycle hook.
    synced_ham_comment.update_columns(approved: true, spam: false)
    synced_spam_comment.update_columns(approved: false, spam: true)
    unsynced_ham_comment.update_columns(approved: true, spam: true)
    unsynced_spam_comment.update_columns(approved: false, spam: false)
    unsynced_spam_comment_two.update_columns(approved: false, spam: false)
  end

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
