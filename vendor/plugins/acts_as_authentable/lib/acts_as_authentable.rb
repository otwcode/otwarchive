module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Authentable
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods

        def acts_as_authentable(bells_and_whistles = true)
          send :include, AuthentableEntity
          # Add features that apply to users but not to admins, or vice versa
          if bells_and_whistles
            send :include, SessionPersistence
          end
        end

        COLUMNS = { :login => :string,
                    :email => :string,
                    :crypted_password => :string,
                    :salt => :string,
                    :remember_token => :string,
                    :remember_token_expires_at => :datetime,
                    :activation_code => :string,
                    :activated_at => :datetime}.freeze
                    
        ADMIN_COLUMNS = { :login => :string,
                          :email => :string,
                          :crypted_password => :string,
                          :salt => :string}.freeze


        def add_authentable_fields
          COLUMNS.each do |column, type|
            self.connection.add_column table_name, column, type
          end
        end

        def remove_authentable_fields
          COLUMNS.each_key do |column|
            self.connection.remove_column table_name, column
          end
        end
        
        def add_admin_fields
          ADMIN_COLUMNS.each do |column, type|
            self.connection.add_column table_name, column, type
          end
        end

        def remove_admin_fields
          ADMIN_COLUMNS.each_key do |column|
            self.connection.remove_column table_name, column
          end
        end
        
      end
    end
  end
end
