# Preview all emails at http://localhost:3000/rails/mailers/tag_wrangling_admin_mailer
class TagWranglingAdminMailerPreview < ApplicationMailerPreview
  # Sent to tag wrangling supervisors when a tag wrangler changes their username
  def wrangler_username_change_notification
    TagWranglingAdminMailer.wrangler_username_change_notification("stack inserter", "bulk inserter")
  end
end
