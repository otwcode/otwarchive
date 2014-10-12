class KudoMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'
  helper :mailer
  default :from => "Archive of Our Own " + "<#{ArchiveConfig.RETURN_ADDRESS}>"

  # send a batched-up notification 
  # user_kudos is a hash of arrays converted to JSON string format
  # [commentable_type]_[commentable_id] => [array of users who left kudos with the last entry being "# guests" if any]
  def batch_kudo_notification(user_id, user_kudos)
    @commentables = []
    @kudo_givers = {}
    user = User.find(user_id)
    kudos_hash = JSON.parse(user_kudos)
    I18n.with_locale(Locale.find(user.preference.prefered_locale).iso) do
      kudos_hash.each_pair do |commentable_info, kudo_givers|
        commentable_type, commentable_id, guest_count  = commentable_info.split('_')
        commentable = commentable_type.constantize.find_by_id(commentable_id)
        if guest_count.to_i == 1 then kudo_givers << "#{t 'mailer.kudos.guest'}" end 
        if guest_count.to_i > 1 then kudo_givers << "#{guest_count} #{t 'mailer.kudos.guests'}" end 
        next unless commentable
        @commentables << commentable
        @kudo_givers[commentable_id] = kudo_givers
      end
      mail(
        :to => user.email,
        :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] #{t 'mailer.kudos.youhave'}"
      )
    end
    ensure
     I18n.locale = I18n.default_locale
  end

end
