module CreatorshipTests
  extend ActiveSupport::Concern

  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors
  attr_accessor :authors_to_remove
  attr_accessor :invalid_pseuds
  attr_accessor :disallowed_pseuds
  attr_accessor :ambiguous_pseuds

  before_save :validate_authors

  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.blank? && self.is_a?(Work)
      errors.add(:base, ts("Work must have at least one author."))
      throw :abort
    end

    if (invalid_pseuds & disallowed_pseuds).present?
      errors.add(:base, ts("These pseuds do not allow others to add them as co-creator: %{pseuds}.", pseuds: (invalid_pseuds & disallowed_pseuds).to_sentence))
    end

    if (invalid_pseuds - disallowed_pseuds).present?
      errors.add(:base, ts("These pseuds are invalid: %{pseuds}.", pseuds: (invalid_pseuds - disallowed_pseuds).to_sentence))
    end
    throw :abort
  end

  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    selected_pseuds = Pseud.find(attributes[:ids])
    (self.authors ||= []) << selected_pseuds
    # if current user has selected different pseuds
    current_user = User.current_user
    if current_user.is_a? User
      self.authors_to_remove = current_user.pseuds & (self.pseuds - selected_pseuds)
    end
    self.authors << Pseud.find(attributes[:ambiguous_pseuds]) if attributes[:ambiguous_pseuds]
    if !attributes[:byline].blank?
      results = Pseud.parse_bylines(attributes[:byline], keep_ambiguous: true, remove_disallowed: true)
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds]
      self.disallowed_pseuds = results[:disallowed_pseuds]
      if results[:banned_pseuds].present?
        self.errors.add(
            :base,
            ts("%{name} is currently banned and cannot be listed as a co-creator.",
               name: results[:banned_pseuds].to_sentence
            )
        )
      end
    end
    self.authors.flatten!
    self.authors.uniq!
  end

end