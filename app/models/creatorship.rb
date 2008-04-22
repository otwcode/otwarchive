class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true

  def self.add_authors(creation, pseuds)
    for pseud in pseuds
      unless creation.pseuds.include?(pseud)
        pseud.add_creations(creation)
      end
    end
  end
  
end
