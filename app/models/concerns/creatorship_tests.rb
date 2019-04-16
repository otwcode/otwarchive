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
          errors.add(:base, ts("%{pseud}: does not allow others to add them as a co-creator.",p))
        else
          errors.add(:base, ts("%{pseud}: Is invalid",p))
        end
      end
      puts "error"
      throw :abort
    end
  end

end