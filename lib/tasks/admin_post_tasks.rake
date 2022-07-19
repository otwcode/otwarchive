namespace :admin_post do
  desc "Disable commenting on admin posts more than ADMIN_POST_COMMENTING_EXPIRATION_DAYS days old"
  task(expire_commenting: :environment) do
    return unless ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS.positive?

    AdminPost.where.not(comment_permissions: :disable_all)
      .where(created_at: (Time.current - ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS.days)..)
      .update_all(comment_permissions: :disable_all)

    puts "Commenting disabled for admin posts older than #{ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS} days."
  end
end
