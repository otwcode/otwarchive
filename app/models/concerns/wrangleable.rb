module Wrangleable
  extend ActiveSupport::Concern

  included do
    after_save :update_last_wrangling_activity, if: :update_wrangling_activity?
    after_destroy :update_last_wrangling_activity, if: :update_wrangling_activity?
  end

  private

  def update_last_wrangling_activity
    current_user = User.current_user
    return unless current_user.respond_to?(:is_tag_wrangler?) && current_user.is_tag_wrangler?

    last_activity = LastWranglingActivity.find_or_create_by(user: current_user)
    last_activity.touch
  end

  def update_wrangling_activity?
    User.update_wrangling_activity
  end
end
