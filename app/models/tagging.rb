class Tagging < ActiveRecord::Base
  belongs_to :tag, :polymorphic => true
  belongs_to :tagger, :polymorphic => true
  
  acts_as_double_polymorphic_join(
    :tags => [:labels],    # models that can be used as tags
    :taggers => [:works, :bookmarks, :labels]  # models that can be tagged
  )

  # work.tags are the tags added to a work
  # label.tags are the tags added to a label
  # label.taggers are the objects that have that label added to them

  # TODO only tag wranglers can tag labels (to create a heirarchy)

end
