class AdminMailerPreview < ApplicationMailerPreview
  # Sent to an admin when they get a comment on an admin post
  def comment_notification
    commenter = create(:user, login: "user#{Faker::Lorem.characters(number: 8)}")
    commenter_pseud = create(:pseud, user: commenter, name: "custom pseud")
    comment = create(:comment, pseud: commenter_pseud)
    AdminMailer.comment_notification(comment.id)
  end

  # Sent to an admin when they get a comment on an admin post by an official user
  def comment_notification_official
    commenter = create(:official_user, login: "user#{Faker::Lorem.characters(number: 8)}")
    comment = create(:comment, pseud: commenter.default_pseud)
    AdminMailer.comment_notification(comment.id)
  end

  # Sent to an admin when they get a comment on an admin post by a guest
  def comment_notification_guest
    comment = create(:comment, :by_guest)
    AdminMailer.comment_notification(comment.id)
  end

  # Sent to an admin when a comment on an admin post is edited
  def edited_comment_notification
    commenter = create(:user, login: "user#{Faker::Lorem.characters(number: 8)}")
    comment = create(:comment, pseud: commenter.default_pseud)
    AdminMailer.edited_comment_notification(comment.id)
  end
end
