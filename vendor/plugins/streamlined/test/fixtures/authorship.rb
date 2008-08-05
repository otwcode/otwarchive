class Authorship < ActiveRecord::Base
  belongs_to :author
  belongs_to :publication, :polymorphic => true
  belongs_to :article,  :class_name => "Article",
                        :foreign_key => "publication_id"
  belongs_to :book,     :class_name => "Book",
                        :foreign_key => "publication_id"  
  delegates :author_name, :to=>:author, :method=>:full_name
  
  # example for showing that non AR methods are not accidentally processed as associations
  def non_ar_method; end
  delegates :another_non_ar_method, :to => :non_ar_method
end
