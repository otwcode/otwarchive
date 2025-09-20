require "spec_helper"

describe "rake search:index_admin_users" do
  it "deletes and recreates the admin user search index and populates it" do
    user = create(:user)
    expect(UserIndexer).to receive(:delete_index).and_call_original
    expect(UserIndexer).to receive(:create_index).and_call_original
    expect(UserIndexer).to receive(:new).with([user.id.to_s]).and_call_original
    subject.invoke
  end
end

describe "rake search:index_collections" do
  it "deletes and recreates the collections index and populates it" do
    collection = create(:collection)
    expect(CollectionIndexer).to receive(:delete_index).and_call_original
    expect(CollectionIndexer).to receive(:create_index).and_call_original
    expect(CollectionIndexer).to receive(:new).with([collection.id.to_s]).and_call_original
    subject.invoke
  end
end

describe "rake search:reindex_admin_users" do
  it "reindexes users for the admin user search" do
    user = create(:user)
    expect(UserIndexer).to receive(:new).with([user.id.to_s]).and_call_original
    subject.invoke
  end
end

describe "rake search:reindex_collections" do
  it "reindexes collections" do
    collection = create(:collection)
    expect(CollectionIndexer).to receive(:new).with([collection.id.to_s]).and_call_original
    subject.invoke
  end
end

describe "rake search:run_world_index_queue" do
  it "reindexes collections" do
    collection = create(:collection)
    IndexQueue.enqueue(collection, :world)
    expect(CollectionIndexer).to receive(:new)
     .with([collection.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes works" do
    work = create(:work)
    IndexQueue.enqueue(work, :world)
    expect(WorkIndexer).to receive(:new)
      .with([work.id.to_s]).and_call_original
    expect(BookmarkedWorkIndexer).to receive(:new)
      .with([work.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes pseuds" do
    pseud = create(:pseud)
    IndexQueue.enqueue(pseud, :world)
    expect(PseudIndexer).to receive(:new)
      .with([pseud.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes tags" do
    tag = create(:tag)
    IndexQueue.enqueue(tag, :world)
    expect(TagIndexer).to receive(:new)
      .with([tag.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes bookmarks" do
    bookmark = create(:bookmark)
    IndexQueue.enqueue(bookmark, :world)
    expect(BookmarkIndexer).to receive(:new)
      .with([bookmark.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes series" do
    series = create(:series)
    IndexQueue.enqueue(series, :world)
    expect(BookmarkedSeriesIndexer).to receive(:new)
      .with([series.id.to_s]).and_call_original

    subject.invoke
  end

  it "reindexes external works" do
    external_work = create(:external_work)
    IndexQueue.enqueue(external_work, :world)
    expect(BookmarkedExternalWorkIndexer).to receive(:new)
      .with([external_work.id.to_s]).and_call_original

    subject.invoke
  end
end

describe "rake search:index_tags" do
  let(:prompt) { "Running this task will temporarily empty some wrangling bins and affect tag search.\n      Have you warned the wrangling team this task is being run?\n      Enter YES to continue:\n" }
  it "recreates tag index with user confirmation" do
    tag = create(:tag)
    IndexQueue.enqueue(tag, :world)
  
    allow($stdin).to receive(:gets).and_return("yes")
    expect { subject.invoke }
      .to output(prompt.to_s)
      .to_stdout
  end
  
  it "does not complete tag index when user does not enter yes" do
    tag = create(:tag)
    IndexQueue.enqueue(tag, :world)
    
    # Do not set up an expectation for TagIndexer.index_all
    allow($stdin).to receive(:gets).and_return("no")
    begin
      expect { subject.invoke }
        .to output("#{prompt}\nTask aborted.")
        .to_stdout
    rescue SystemExit # rubocop:disable Lint/SuppressedException
    end
  end
end

describe "rake search:timed_collections" do
  it "reindexes collections from the past day" do
    travel_to(1.day.ago) do
      create(:collection)
    end
    collection = create(:collection)
    expect(CollectionIndexer).to receive(:new).with([collection.id.to_s]).and_call_original
    subject.invoke
  end
end

describe "rake search:timed_all" do
  it "reindexes admin users from the past day" do
    travel_to(1.day.ago) do
      create(:user)
    end
    user = create(:user)
    expect(UserIndexer).to receive(:new).with([user.id.to_s]).and_call_original
    subject.invoke
  end

  it "reindexes collections from the past day" do
    travel_to(1.day.ago) do
      create(:collection)
    end
    collection = create(:collection)
    expect(CollectionIndexer).to receive(:new).with([collection.id.to_s]).and_call_original
    subject.invoke
  end
end
