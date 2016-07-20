# User namespace and class
class User
  # Handle Devise user confirmation and assign external works if any
  class ConfirmationsController < Devise::ConfirmationsController
    skip_after_filter :store_location

    def show
      super do |user|
        break unless resource.errors.empty?

        user.create_log_item(action: ArchiveConfig.ACTION_ACTIVATE)

        # assign over any external authors that belong to this user
        external_authors = []
        external_authors << ExternalAuthor.find_by_email(user.email)

        invitation = user.invitation
        external_authors << invitation.external_author if invitation

        external_authors.compact!

        break if external_authors.empty?

        external_authors.each { |author| author.claim!(user) }

        @has_works = true
      end
    end

    protected

    def after_confirmation_path_for(resource_name, resource)
      if @has_works
        flash[:notice] += ts(" We found some works already uploaded to the Archive of Our Own that we think belong to you! You'll see them on your homepage when you've logged in.")
      end

      super(resource_name, resource)
    end
  end
end
