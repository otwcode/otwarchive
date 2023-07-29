module PseudsHelper
  # Returns a list of pseuds, with links to each pseud.
  #
  # Used on Profile page, and by ProfileController#pseuds.
  #
  # The pseuds argument should be a single page of the user's pseuds, generated
  # by calling user.pseuds.paginate(page: 1) or similar. This allows us to
  # insert a remote link to dynamically insert the next page of pseuds.
  def print_pseud_list(user, pseuds, first: true)
    links = pseuds.map do |pseud|
      link_to(pseud.name, [user, pseud])
    end

    difference = pseuds.total_entries - pseuds.length - pseuds.offset

    if difference.positive?
      links << link_to(
        t("profile.pseud_list.more_pseuds", count: difference),
        pseuds_user_profile_path(user, page: pseuds.next_page),
        remote: true, id: "more_pseuds"
      )
    end

    more_pseuds_connector = tag.span(
      t("support.array.last_word_connector"),
      id: "more_pseuds_connector"
    )

    if first
      to_sentence(links,
                  last_word_connector: more_pseuds_connector)
    else
      links.unshift("")
      to_sentence(links,
                  last_word_connector: more_pseuds_connector,
                  two_words_connector: more_pseuds_connector)
    end
  end

  def pseuds_for_sidebar(user, pseud)
    pseuds = user.pseuds.abbreviated_list - [pseud]
    pseuds = pseuds.sort
    pseuds = [pseud] + pseuds if pseud && !pseud.new_record?
    pseuds
  end

  # used in the sidebar
  def pseud_selector(pseuds)
    pseuds.collect { |pseud| "<li>#{span_if_current(pseud.name, [pseud.user, pseud])}</li>" }.join.html_safe
  end
end
