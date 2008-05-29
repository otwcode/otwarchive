class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true

  def self.add_authors(creation, pseuds)
    pseuds.each { |p| p.add_creations([creation]) } if pseuds
  end
  
end
