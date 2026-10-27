class ChallengeSearchForm < CollectionSearchForm
  
  def sort_options
    [
      ["Date Sign-ups Close", "signups_close_at"],
      ["Date Created", "created_at"],
      ["Title", "title.keyword"]
    ].freeze
  end

  def default_sort_column
    "signups_close_at"
  end

  def default_sort_direction
    return "desc" if sort_column == "signups_close_at"

    super
  end
end
