require File.dirname(__FILE__) + '/exceptions'

# Provides the appearance of dynamically generated methods on the roles database.
#
# Examples:
#   user.is_member?                     --> Returns true if user has any role of "member"
#   user.is_member_of? this_workshop    --> Returns true/false. Must have authorizable object after query.
#   user.is_eligible_for [this_award]   --> Gives user the role "eligible" for "this_award"
#   user.is_moderator                   --> Gives user the general role "moderator" (not tied to any class or object)
#   user.is_candidate_of_what           --> Returns array of objects for which this user is a "candidate" (any type)
#   user.is_candidate_of_what(Party)    --> Returns array of objects for which this user is a "candidate" (only 'Party' type)
#
#   model.has_members                   --> Returns array of users which have role "member" on that model
#   model.has_members?                  --> Returns true/false
#
module Authorization
  module Identity

    module UserExtensions
      module InstanceMethods

        def method_missing( method_sym, *args )
          method_name = method_sym.to_s
          authorizable_object = args.empty? ? nil : args[0]

          base_regex = "is_(\\w+)"
          fancy_regex = base_regex + "_(#{Authorization::Base::VALID_PREPOSITIONS_PATTERN})"
          is_either_regex = '^((' + fancy_regex + ')|(' + base_regex + '))'
          base_not_regex = "is_no[t]?_(\\w+)"
          fancy_not_regex = base_not_regex + "_(#{Authorization::Base::VALID_PREPOSITIONS_PATTERN})"
          is_not_either_regex = '^((' + fancy_not_regex + ')|(' + base_not_regex + '))'

          if method_name =~ Regexp.new(is_either_regex + '_what$')
            role_name = $3 || $6
            has_role_for_objects(role_name, authorizable_object)
          elsif method_name =~ Regexp.new(is_not_either_regex + '\?$')
            role_name = $3 || $6
            not is_role?( role_name, authorizable_object )
          elsif method_name =~ Regexp.new(is_either_regex + '\?$')
            role_name = $3 || $6
            is_role?( role_name, authorizable_object )
          elsif method_name =~ Regexp.new(is_not_either_regex + '$')
            role_name = $3 || $6
            is_no_role( role_name, authorizable_object )
          elsif method_name =~ Regexp.new(is_either_regex + '$')
            role_name = $3 || $6
            is_role( role_name, authorizable_object )
          else
            super
          end
        end

        private

        def is_role?( role_name, authorizable_object )
          if authorizable_object.nil?
            return self.has_role?(role_name)
          elsif authorizable_object.respond_to?(:accepts_role?)
            return self.has_role?(role_name, authorizable_object)
          end
          false
        end

        def is_no_role( role_name, authorizable_object = nil )
          if authorizable_object.nil?
            self.has_no_role role_name
          else
            self.has_no_role role_name, authorizable_object
          end
        end

        def is_role( role_name, authorizable_object = nil )
          if authorizable_object.nil?
            self.has_role role_name
          else
            self.has_role role_name, authorizable_object
          end
        end

        def has_role_for_objects(role_name, type)
          if type.nil?
            roles = self.roles.find_all_by_name( role_name )
          else
            roles = self.roles.find_all_by_authorizable_type_and_name( type.name, role_name )
          end
          roles.collect do |role|
            if role.authorizable_id.nil?
              role.authorizable_type.nil? ?
                nil : Module.const_get( role.authorizable_type )   # Returns class
            else
              role.authorizable
            end
          end
        end
      end
    end

    module ModelExtensions
      module InstanceMethods

        def method_missing( method_sym, *args )
          method_name = method_sym.to_s
          if method_name =~ /^has_(\w+)\?$/
            role_name = $1.singularize
            self.accepted_roles.find_all_by_name(role_name).any? { |role| role.users.any? }
          elsif method_name =~ /^has_(\w+)$/
            role_name = $1.singularize
            users = self.accepted_roles.find_all_by_name(role_name).collect { |role| role.users }
            users.flatten.uniq if users
          else
            super
          end
        end

      end
    end

  end
end
