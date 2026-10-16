class KudoMailerPreview < ApplicationMailerPreview
  # Sends a kudos notification
  def batch_kudo_notification
    user = create(:user)
    work = create(:work)
    guest_count = params[:guest_count] || 1
    user_count = params[:user_count] || 1
    names = Array.new(user_count.to_i) { "User#{Faker::Alphanumeric.alpha(number: 8)}" }
    hash = { "Work_#{work.id}": { guest_count:, names: } }
    KudoMailer.batch_kudo_notification(user.id, hash.to_json)
  end
end
