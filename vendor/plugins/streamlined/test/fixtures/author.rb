class Author < ActiveRecord::Base
  has_many :authorships
  has_many :articles, :through => :authorships, :source => :article,
                      :conditions => "authorships.publication_type = 'Article'"
  has_many :books,    :through => :authorships, :source => :book,
                      :conditions => "authorships.publication_type = 'Book'"
  def full_name
    "#{first_name} #{last_name}"
  end
end

