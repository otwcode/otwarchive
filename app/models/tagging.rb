class Tagging < ActiveRecord::Base
  belongs_to :tagger, :polymorphic => true, :counter_cache => true
  belongs_to :taggable, :polymorphic => true

  validates_presence_of :tagger, :taggable
  before_destroy :delete_unused_tags

  # Gets rid of unwrangled tags that aren't tagging anything else
  def delete_unused_tags
    tagger.destroy if (tagger.unwrangled && tagger.taggings == [self])
  end

end
