class Tagging < ActiveRecord::Base
  belongs_to :tagger, :polymorphic => true, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  
  validates_presence_of :tagger, :taggable
  before_create :check_for_synonyms
  before_destroy :delete_unused_tags
  after_create :update_fandom, :update_genre

  # Tag with canonical synonym instead, if it exists
  def check_for_synonyms
    synonym = self.tagger.synonym
    self.tagger = synonym if synonym
  end 
  
  # Gets rid of unwrangled tags that aren't tagging anything else
  def delete_unused_tags
    tagger.destroy if (tagger.unwrangled? && tagger.taggings == [self])
  end

  def update_fandom
    tagger.update_fandom if tagger.unwrangled?
  end

  def update_genre
    if tagger.is_a?(Freeform)
      if tagger.genre && taggable.is_a?(Work)
        taggable.genres << tagger.genre
      end
    end
  end

end
