module AuthorAdditions
  def full_name
    "#{first_name} #{last_name}"
  end
end

Author.class_eval {include AuthorAdditions}