# Authorization plugin configuration goes here
#
# See http://github.com/ianterrell/permityo/tree/ Settings section for details on what can be configured, 
# although most defaults are sensible. 

module Otwarchive
  class Application < Rails::Application

    # Which flash key we stick error messages into
    config.permit_yo.require_user_flash = :error
    config.permit_yo.permission_denied_flash = :error

    # Where users get redirected if they are not currently logged in
    config.permit_yo.require_user_redirection = {controller: :user_sessions, action: :new}
  end
end

module PermitYo
  module Default
    module UserExtensions
      module InstanceMethods
        
        # Determine if the current model has a particular role
        # depends on the model having a relationship with roles! (eg, has_and_belongs_to_many :roles)
        def has_role?(role_name)
          role = Role.find_by_name(role_name)
          self.roles.include?(role)
        end

        # Method for setting or removing a particular role on a model
        # depends on the model having a relationship with roles! (eg, has_and_belongs_to_many :roles)
        def set_role(role_name, should_have_role)
          role = Role.find_or_create_by_name(role_name)
          if should_have_role
            unless self.roles.include?(role)
              self.roles << role
              self.create_log_item( options = {action: ArchiveConfig.ACTION_ADD_ROLE, role_id: role.id, note: 'Change made by Admin'})
            end
          else
            if self.roles.include?(role)
              self.roles.delete(role)
              self.create_log_item( options = {action: ArchiveConfig.ACTION_REMOVE_ROLE, role_id: role.id, note: 'Change made by Admin'})
            end
          end
        end

      end
    end
  end
end
