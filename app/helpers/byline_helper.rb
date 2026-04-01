module BylineHelper
  def byline(creation, options = {})
    if creation.respond_to?(:anonymous?) && creation.anonymous?
      anon_byline = t("byline_helper.anonymous_byline")
      anon_byline = t("byline_helper.anonymous_with_name_byline_html", pseud_byline: non_anonymous_byline(creation, options[:only_path])) if anonymous_with_name?(options, creation)
      return anon_byline
    end
    non_anonymous_byline(creation, options[:only_path])
  end

  # A plain text version of the byline, for when we don't want to deliver a linkified version.
  def text_byline(creation, options = {})
    if creation.respond_to?(:anonymous?) && creation.anonymous?
      anon_byline = t("byline_helper.anonymous_byline")
      anon_byline = t("byline_helper.anonymous_with_name_byline_html", pseud_byline: non_anonymous_byline(creation)) if anonymous_with_name?(options, creation)
      anon_byline
    else
      only_path = false
      byline_text(creation, only_path, text_only: true)
    end
  end

  def creators_for_feed(creation)
    if creation.anonymous?
      yield t("byline_helper.anonymous_byline")
    else
      creators = byline_data(creation)
      creators.each do |creator|
        pseud_byline = creator[:byline]

        if creator[:external_creators].empty?
          yield pseud_byline, byline_creator_url(creator, false)
        else
          creator[:external_creators].map do |ext_creator|
            yield t("byline_helper.archivist_byline_html", external_creator: ext_creator, pseud_byline: pseud_byline)
          end
        end
      end
    end
  end

  private

  # Creation is anonymous but current user/admin should see the creator
  def anonymous_with_name?(options, creation)
    options[:visibility] != "public" && (logged_in_as_admin? || is_author_of?(creation))
  end

  def non_anonymous_byline(creation, url_path = nil)
    only_path = url_path.nil? ? true : url_path

    # Skip cache in preview mode
    return byline_text_uncached(creation, only_path) if @preview_mode # rubocop:disable Rails/HelperInstanceVariable

    byline_text(creation, only_path)
  end

  def byline_text(creation, only_path, text_only: false)
    creators = byline_data(creation)
    byline_text_internal(creators, only_path, text_only)
  end

  def byline_text_uncached(creation, only_path, text_only: false)
    creators = byline_data_uncached(creation)
    byline_text_internal(creators, only_path, text_only)
  end

  def byline_text_internal(creators, only_path, text_only)
    return creators if creators.is_a?(String)

    safe_join(creators.map do |creator|
      pseud_byline = creator[:byline]
      pseud_byline = link_to(pseud_byline, byline_creator_url(creator, only_path), rel: "author") unless text_only

      if creator[:external_creators].empty?
        pseud_byline
      else
        safe_join(creator[:external_creators].map do |ext_creator|
          t("byline_helper.archivist_byline_html", external_creator: ext_creator, pseud_byline: pseud_byline)
        end, t("support.array.words_connector"))
      end
    end, t("support.array.words_connector"))
  end

  def byline_creator_url(creator, only_path)
    user_pseud_url(user_id: creator[:user], id: creator[:pseud], only_path: only_path)
  end

  def byline_data(creation)
    # Update Series#expire_byline_cache and Chapter#expire_byline_cache when changing cache key here
    Rails.cache.fetch(["byline_data", creation.cache_key]) { byline_data_uncached(creation) }
  end

  def byline_data_uncached(creation)
    return creation.author if creation.respond_to?(:author)

    pseuds = @preview_mode ? creation.pseuds_after_saving : creation.pseuds.to_a # rubocop:disable Rails/HelperInstanceVariable
    pseuds = pseuds.flatten.uniq.sort

    external_creators = Hash.new []
    if creation.is_a?(Work)
      external_creatorships = creation.external_creatorships.reject(&:claimed?)
      external_creatorships.each do |ec|
        archivist_pseud = pseuds.find { |p| ec.archivist.pseuds.include?(p) }
        external_creators[archivist_pseud] += [ec.author_name]
      end
    end

    pseuds.map do |pseud|
      {
        # Cache the plain-text pseud (username)
        byline: pseud.byline,
        # Cache the parameters that we need for generating the pseud URL later
        # We can't cache the record itself (for later URL generation) since it could change or be deleted
        pseud: pseud.to_param,
        user: pseud.user.to_param,
        # Cache the array of plain-text names of the unclaimed external creators
        external_creators: external_creators[pseud]
      }
    end
  end
end
