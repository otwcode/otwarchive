class Homepage
  def initialize(user)
    @user = user
  end

  def logged_in?
    @user.present?
  end

  def admin_posts
    if Rails.env.development?
      @admin_posts = AdminPost.non_translated.for_homepage.all
    else
      @admin_posts = Rails.cache.fetch("home/index/home_admin_posts", expires_in: 20.minutes) do
        AdminPost.non_translated.for_homepage.all
      end
    end
  end

  def favorite_tags
    return unless logged_in?
    if Rails.env.development?
      @favorite_tags ||= @user.favorite_tags
    else
      @favorite_tags ||= Rails.cache.fetch("home/index/#{@user.id}/home_favorite_tags") do
        @user.favorite_tags
      end
    end
  end

  def readings
    return unless logged_in?
    if Rails.env.development?
      @readings ||= @user.readings.order("RAND()").
          limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE).
          where(toread: true).
          all
    else
      @readings ||= Rails.cache.fetch("home/index/#{@user.id}/home_marked_for_later") do
        @user.readings.order("RAND()").
          limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE).
          where(toread: true).
          all
      end
    end
  end

  def inbox_comments
    return unless logged_in?
    @inbox_comments ||= @user.inbox_comments.for_homepage
  end
end
