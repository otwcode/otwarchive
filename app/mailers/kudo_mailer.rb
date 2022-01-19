class KudoMailer < ApplicationMailer
  # send a batched-up notification
  # user_kudos is a hash of arrays converted to JSON string format
  # [commentable_type]_[commentable_id] =>
  #   names: [array of users who left kudos with the last entry being "# guests" if any]
  #   guest_count: number of guest kudos
  def batch_kudo_notification(user_id, user_kudos)
    @commentables = []
    @kudo_givers = {}
    user = User.find(user_id)
    kudos_hash = JSON.parse(user_kudos)

    I18n.with_locale(Locale.find(user.preference.preferred_locale).iso) do
      kudos_hash.each_pair do |commentable_info, kudo_givers_hash|
        # Parse the key to extract the type and id of the commentable - skip if no commentable
        commentable_type, commentable_id = commentable_info.split('_')
        commentable = commentable_type.constantize.find_by(id: commentable_id)
        next unless commentable

        # If we have a commentable, extract names and process guest kudos text - skip if no kudos givers
        names = kudo_givers_hash['names']
        guest_count = kudo_givers_hash['guest_count']
        kudo_givers = []

        if !names.nil? && names.size > 0
          kudo_givers = names
          kudo_givers << guest_kudos(guest_count) unless guest_count == 0
          @kudos_count = names.size + guest_count
        else
          kudo_givers << guest_kudos(guest_count).capitalize unless guest_count == 0
          @kudos_count = guest_count
        end
        next if kudo_givers.empty?

        @commentables << commentable
        @kudo_givers[commentable_info] = kudo_givers
      end
      mail(
        to: user.email,
        subject: t('mailer.kudos.you_have', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
  end

  def guest_kudos(guest_count)
     "#{t('mailer.kudos.guest', count: guest_count.to_i)}"
  end
end
