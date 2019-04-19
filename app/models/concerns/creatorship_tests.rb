module CreatorshipTests
  extend ActiveSupport::Concern


  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.blank? && self.is_a?(Work)
      errors.add(:base, ts("Work must have at least one author."))
      puts "error2"
      throw :abort
    elsif !self.invalid_pseuds.blank?
      errors.add(:base, ts("These pseuds are invalid: ") )
      self.invalid_pseuds.each do |p|
        if self.disallowed_pseuds.include?(p)
          errors.add(:base, ts("%{pseud}: does not allow others to add them as a co-creator.",pseud: p))
        else
          errors.add(:base, ts("%{pseud}: Is invalid",pseud: p))
        end
      end
      throw :abort
    end
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