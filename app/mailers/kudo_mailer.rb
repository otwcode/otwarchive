class KudoMailer < ActionMailer::Base

  default :from => ArchiveConfig.RETURN_ADDRESS

  def kudo_notification(user, kudo)
    @kudo = kudo
    @pseud = kudo.pseud
    @commentable = kudo.commentable
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Kudos on " + kudo.commentable.commentable_name
    )
  end

end
