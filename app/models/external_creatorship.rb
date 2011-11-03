class ExternalCreatorship < ActiveRecord::Base
  belongs_to :external_author_name, :inverse_of => :external_creatorships
  belongs_to :archivist, :class_name => 'User', :foreign_key => 'archivist_id'
  belongs_to :creation, :polymorphic => true  , :inverse_of => :external_creatorships
  
  def external_author=(external_author)
    self.external_author_name = external_author.default_name
  end
  
  def external_author
    self.external_author_name.external_author
  end
  
  def claimed?
    self.external_author_name.external_author.claimed?
  end
  
  def to_s
    ts("%{title} by %{name}", :title => self.creation.title, :name => self.external_author_name)
  end
end
