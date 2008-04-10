require File.dirname(__FILE__) + '/exceptions'

# In order to use this mixin, you'll need to define roles by overriding the
# following functions:
#
# User#has_role?(role)
#   Return true or false depending on the roles (strings) passed in.
#
# Model#accepts_role?(role, user)
#   Return true or false depending on the roles (strings) this particular user has for
#   this particular model object.
#
# See http://www.writertopia.com/developers/authorization

module Authorization
  module HardwiredRoles

    module UserExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorized_user
          include Authorization::HardwiredRoles::UserExtensions::InstanceMethods
        end
      end

      module InstanceMethods
        # If roles aren't explicitly defined in user class then return false
        def has_role?( role, authorizable_object = nil )
          false
        end

        def has_role( role, authorizable_object = nil )
          raise( CannotSetRoleWhenHardwired,
            "Hardwired mixin: Cannot set user to role #{role}. Don't use #has_role, use code in models."
          )
        end

        def has_no_role( role, authorizable_object = nil )
          raise( CannotSetRoleWhenHardwired,
            "Hardwired mixin: Cannot remove user role #{role}. Don't use #has_no_role, use code in models."
          )
        end
      end
    end

    module ModelExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorizable
          include Authorization::HardwiredRoles::ModelExtensions::InstanceMethods
        end
      end

      module InstanceMethods
        def accepts_role?( role, user )
          return false
        end

        def accepts_role( role, user )
          raise( CannotSetRoleWhenHardwired,
            "Hardwired mixin: Cannot set user to role #{role}. Don't use #accepts_role, use code in models."
          )
        end

        def accepts_no_role( role, user )
          raise( CannotSetRoleWhenHardwired,
            "Hardwired mixin: Cannot set user to role #{role}. Don't use #accepts_no_role, use code in models."
          )
        end
      end
    end

  end

end

