module SearchCounts
  module_function

  ######################################################################
  # COUNTS OF ITEMS IN COLLECTIONS
  ######################################################################

  def collection_works_query(collection)
    WorkQuery.new(collection_ids: [collection.id],
                  show_restricted: User.current_user.present?)
  end

  def collection_bookmarks_query(collection)
    BookmarkQuery.new(collection_ids: [collection.id],
                      show_restricted: User.current_user.present?)
  end

  def work_count_for_collection(collection)
    Rails.cache.fetch(collection_cache_key(collection, :works),
                      collection_cache_options) do
      collection_works_query(collection).count
    end
  end

  def bookmarkable_count_for_collection(collection)
    Rails.cache.fetch(collection_cache_key(collection, :bookmarkables),
                      collection_cache_options) do
      collection_bookmarks_query(collection).bookmarkable_query.count
    end
  end

  def fandom_count_for_collection(collection)
    Rails.cache.fetch(collection_cache_key(collection, :fandom_count),
                      collection_cache_options) do
      get_fandom_hash(collection_works_query(collection)).count
    end
  end

  def fandom_ids_for_collection(collection)
    Rails.cache.fetch(collection_cache_key(collection, :fandom_ids),
                      collection_cache_options) do
      get_fandom_hash(collection_works_query(collection))
    end
  end

  def collection_cache_key(collection, key)
    "collection_count_#{collection.id}_#{key}_#{logged_in}"
  end

  ######################################################################
  # WORK COUNTS FOR USER/PSEUD DASHBOARD
  ######################################################################

  def work_count_for_user(user)
    Rails.cache.fetch(work_cache_key(user), dashboard_cache_options) do
      WorkQuery.new(user_ids: [user.id]).count
    end
  end

  def work_count_for_pseud(pseud)
    Rails.cache.fetch(work_cache_key(pseud), dashboard_cache_options) do
      WorkQuery.new(pseud_ids: [pseud.id]).count
    end
  end

  # If we want to invalidate cached counts whenever the owner (which for
  # this method can only be a user or a pseud) has a new work, we can use
  # "#{owner.works_index_cache_key}" instead of "#{owner.model_name.cache_key}_#{owner.id}".
  # See lib/works_owner.rb.
  def work_cache_key(owner)
    "work_count_#{owner.model_name.cache_key}_#{owner.id}_#{logged_in}"
  end

  ######################################################################
  # COLLECTION COUNTS FOR USER/PSEUD DASHBOARD
  ######################################################################

  def collection_count_for_user(user)
    Rails.cache.fetch(["user", user.id, "collections_count"], dashboard_cache_options) do
      CollectionQuery.new(maintainer_id: user.id).count
    end
  end

  ######################################################################
  # BOOKMARK COUNTS FOR USER/PSEUD DASHBOARD
  ######################################################################

  def bookmark_count_for_user(user)
    show_private = User.current_user.is_a?(Admin) || user == User.current_user

    Rails.cache.fetch(bookmark_cache_key(user, show_private), dashboard_cache_options) do
      BookmarkQuery.new(user_ids: [user.id], show_private: show_private).count
    end
  end

  def bookmark_count_for_pseud(pseud)
    show_private = User.current_user.is_a?(Admin) || pseud.user == User.current_user

    Rails.cache.fetch(bookmark_cache_key(pseud, show_private), dashboard_cache_options) do
      BookmarkQuery.new(pseud_ids: [pseud.id], show_private: show_private).count
    end
  end

  def bookmark_cache_key(owner, show_private)
    private_status = show_private ? "_private" : ""
    "bookmark_count_#{owner.model_name.cache_key}_#{owner.id}_#{logged_in}#{private_status}"
  end

  ######################################################################
  # USEFUL FUNCTIONS
  ######################################################################

  def logged_in
    User.current_user ? :logged_in : :logged_out
  end

  # Helper function to get both categorized and uncategorized fandoms from a WorkQuery object
  def get_fandom_hash(query)
    list = []
    query.search_results.each do |work|
      work.fandoms.each do |fandom|
        if fandom.unwrangled? || fandom.canonical?
          list.push(fandom.id)
        else
          list.push(fandom.merger_id)
        end
      end
    end
    list.tally
  end

  ######################################################################
  # CACHE OPTIONS
  ######################################################################

  # Options for the dashboard (user/pseud) caches.
  def dashboard_cache_options
    {
      expires_in: ArchiveConfig.SECONDS_UNTIL_DASHBOARD_COUNTS_EXPIRE.seconds,
      race_condition_ttl: 10.seconds
    }
  end

  # Options for the collection caches.
  def collection_cache_options
    {
      expires_in: ArchiveConfig.SECONDS_UNTIL_COLLECTION_COUNTS_EXPIRE.seconds,
      race_condition_ttl: 10.seconds
    }
  end
end
