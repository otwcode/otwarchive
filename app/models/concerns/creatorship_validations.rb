# frozen_string_literal: true

module CreatorshipValidations
  extend ActiveSupport::Concern

  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors
  attr_accessor :authors_to_remove
  attr_accessor :invalid_pseuds
  attr_accessor :disallowed_pseuds
  attr_accessor :ambiguous_pseuds

  # Checks that work has valid pseuds.
  def validate_authors
    if self.authors.blank? && self.pseuds.blank? && self.is_a?(Work)
      errors.add(:base, ts("Work must have at least one author."))
      throw :abort
    elsif !self.invalid_pseuds.blank?
      errors.add(:base, ts("These pseuds are invalid: "))
      self.invalid_pseuds.each do |p|
        if self.disallowed_pseuds.include?(p)
          errors.add(:base, ts("%{pseud}: does not allow others to add them as a co-creator.", pseud: p))
        else
          errors.add(:base, ts("%{pseud}: Is invalid", pseud: p))
        end
      end
      throw :abort
    end
  end

  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    selected_pseuds = attributes[:ids].map { |p| Pseud.find(p) }
    (self.authors ||= []) << selected_pseuds
    # if current user has selected different pseuds
    current_user = User.current_user
    if current_user.is_a? User
      self.authors_to_remove = current_user.pseuds & (self.pseuds - selected_pseuds)
    end
    self.authors << attributes[:ambiguous_pseuds].map { |p| Pseud.find(p) } if attributes[:ambiguous_pseuds]
    unless attributes[:byline].blank?
      whitelist = []
      whitelist = self.works&.collect{ |w| w.pseuds.collect(&:id) }&.flatten if self.is_a?(Series)
      whitelist = self.work&.pseuds&.collect(&:id)&.flatten if self.is_a?(Chapter)
      results = Pseud.parse_bylines(attributes[:byline], keep_ambiguous: true, remove_disallowed: true, whitelist: whitelist)
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds]
      self.disallowed_pseuds = results[:disallowed_pseuds]
      if results[:banned_pseuds].present?
        self.errors.add(:base,
                        ts("%{name} is currently banned and cannot be listed as a co-creator.",
                           name: results[:banned_pseuds].to_sentence))
      end
    end
    self.authors.flatten!
    self.authors.uniq!
  end
end
