namespace :admin do
  desc "Unsuspend suspended users who have been suspended_until up to 12 hours from now"
  task(:unsuspend_users => :environment) do
    User.where(["suspended_until <= ?", 12.hours.from_now]).update_all("suspended_until = NULL, suspended = false")
    puts "Users unsuspended."
  end

  desc "Resend sign-up notification emails after 24 hours"
  task(:resend_signup_emails => :environment) do
    @users = User.where(confirmed_at: nil, created_at: 48.hours.ago..24.hours.ago)
    @users.each do |user|
      UserMailer.signup_notification(user.id).deliver_later
    end
    puts "Sign-up notification emails resent"
  end
end
