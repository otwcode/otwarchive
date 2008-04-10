require File.dirname(__FILE__) + '/exceptions'
require File.dirname(__FILE__) + '/identity'

module Authorization
  module ObjectRolesTable

    module UserExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorized_user(roles_relationship_opts = {})
          has_and_belongs_to_many :roles, roles_relationship_opts
          include Authorization::ObjectRolesTable::UserExtensions::InstanceMethods
          include Authorization::Identity::UserExtensions::InstanceMethods   # Provides all kinds of dynamic sugar via method_missing
        end
      end

      module InstanceMethods
        # If roles aren't explicitly defined in user class then check roles table
        def has_role?( role_name, authorizable_obj = nil )
          if authorizable_obj.nil?
            self.roles.find_by_name( role_name ) ? true : false    # If we ask a general role question, return true if any role is defined.
          else
            role = get_role( role_name, authorizable_obj )
            role ? self.roles.exists?( role.id ) : false
          end
        end

        def has_role( role_name, authorizable_obj = nil )
          role = get_role( role_name, authorizable_obj )
          if role.nil?
            if authorizable_obj.is_a? Class
              role = Role.create( :name => role_name, :authorizable_type => authorizable_obj.to_s )
            elsif authorizable_obj
              role = Role.create( :name => role_name, :authorizable => authorizable_obj )
            else
              role = Role.create( :name => role_name )
            end
          end
          self.roles << role if role and not self.roles.exists?( role.id )
        end

        def has_no_role( role_name, authorizable_obj = nil  )
          role = get_role( role_name, authorizable_obj )
          if role
            self.roles.delete( role )
            role.destroy if role.users.empty?
          end
        end

        private

        def get_role( role_name, authorizable_obj )
          if authorizable_obj.is_a? Class
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id IS NULL', role_name, authorizable_obj.to_s ] )
          elsif authorizable_obj
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?',
                                        role_name, authorizable_obj.class.base_class.to_s, authorizable_obj.id ] )
          else
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type IS NULL and authorizable_id IS NULL', role_name ] )
          end
        end

      end
    end

    module ModelExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorizable
          has_many :accepted_roles, :as => :authorizable, :class_name => 'Role'

          def accepts_role?( role_name, user )
            user.has_role? role_name, self
          end

          def accepts_role( role_name, user )
            user.has_role role_name, self
          end

          def accepts_no_role( role_name, user )
            user.has_no_role role_name, self
          end

          include Authorization::ObjectRolesTable::ModelExtensions::InstanceMethods
          include Authorization::Identity::ModelExtensions::InstanceMethods   # Provides all kinds of dynamic sugar via method_missing
        end
      end

      module InstanceMethods
        # If roles aren't overriden in model then check roles table
        def accepts_role?( role_name, user )
          user.has_role? role_name, self
        end

        def accepts_role( role_name, user )
          user.has_role role_name, self
        end

        def accepts_no_role( role_name, user )
          user.has_no_role role_name, self
        end
      end
    end

  end
end

