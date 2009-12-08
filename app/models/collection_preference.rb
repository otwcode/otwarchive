class CollectionPreference < ActiveRecord::Base
  
  POSTING_BY_OWNER = 1
  POSTING_BY_MODERATOR = 2
  POSTING_BY_MEMBER = 3
  POSTING_BY_ANYONE = 4
  POSTING_BY_OPTIONS = [ [t('collection_preference.by_owner', :default => "Owners"), POSTING_BY_OWNER],
                         [t('collection_preference.by_moderator', :default => "Moderators"), POSTING_BY_MODERATOR],
                         [t('collection_preference.by_members', :default => "Members"), POSTING_BY_MEMBER],
                         [t('collection_preference.by_anyone', :default => "Anyone"), POSTING_BY_ANYONE] ]
  
  belongs_to :collection
  
  validates_numericality_of :allowed_to_post, :only_integer => true

  validates_inclusion_of :allowed_to_post, :in => [1,2,3,4],
    :message => t('collection_preference.invalid_value', :default => "That is not a valid setting for who is allowed to post.")
  
  def allowed_to_post?(pseud)
    case allowed_to_post
    when POSTING_BY_OWNER
      collection.owners.include?(pseud)
    when POSTING_BY_MODERATOR
      collection.maintainers.include?(pseud)
    when POSTING_BY_MEMBER
      collection.participants.include?(pseud)
    when POSTING_BY_ANYONE
      true
    else
      false
    end
  end

  # def allowed_to_post_name(value)
  #   case value
  #   when POSTING_BY_OWNER
  #     t('collection_preference.by_owner', :default => "Owners")
  #   when POSTING_BY_MODERATOR
  #     t('collection_preference.by_moderator', :default => "Moderators")
  #   when POSTING_BY_MEMBER
  #     t('collection_preference.by_members', :default => "Members")
  #   when POSTING_BY_ANYONE
  #     t('collection_preference.by_anyone', :default => "Anyone")
  #   end
  # end
  # 
    
end
