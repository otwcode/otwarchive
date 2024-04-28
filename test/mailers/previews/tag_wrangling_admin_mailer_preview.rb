# Preview all emails at http://localhost:3000/rails/mailers/tag_wrangling_admin_mailer
class TagWranglingAdminMailerPreview < ApplicationMailerPreview
  def wrangler_username_change_notification
    TagWranglingAdminMailer.wrangler_username_change_notification("inserter", "fast inserter")
  end
end
