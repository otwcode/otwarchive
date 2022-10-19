class Mute < ApplicationRecord
  belongs_to :muter, class_name: "User"
  belongs_to :muted, class_name: "User"

  validates :muter, :muted, presence: true
  validates :muted_id, uniqueness: { scope: :muter_id }

  validate :check_self

  after_create :update_cache
  after_destroy :update_cache

  def check_self
    errors.add(:muted, :self) if muted == muter
  end

  validate :check_official, if: :muted
  def check_official
    errors.add(:muted, :official) if muted.official
  end

  def muted_byline=(byline)
    pseuds = Pseud.parse_byline(byline, assume_matching_login: true)
    self.muted = pseuds.first.user unless pseuds.empty?
  end

  def update_cache
    return Rails.cache.write("muted/#{muter_id}/mute_css", nil) if muter.muted_users.empty?
    
    muted_users_css_classes = muter.muted_users.map { |muted_user| ".user-#{muted_user.id}" }

    Rails.cache.write(
      "muted/#{muter_id}/mute_css", 
      "<style>#{muted_users_css_classes.join(', ')} {display: none !important; visibility: hidden !important;}</style>".html_safe
    )
  end
end
