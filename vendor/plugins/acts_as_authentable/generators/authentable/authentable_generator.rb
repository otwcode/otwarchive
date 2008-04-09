class AuthentableGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      camelized_class_name = class_name.pluralize.gsub(/::/, '')
      underscored_file_path = file_path.gsub(/\//, '_').pluralize
      
      # Adds fewer columns for admin classes
      if class_name.downcase.include? "admin"
      m.migration_template 'admin_migration.rb', 'db/migrate', :assigns => {
          :migration_name => "AddAuthentableFieldsFor#{camelized_class_name}"
        }, :migration_file_name => 'add_authentable_fields_for_' +
                                   underscored_file_path      
      else
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
            :migration_name => "AddAuthentableFieldsFor#{camelized_class_name}"
          }, :migration_file_name => 'add_authentable_fields_for_' +
                                     underscored_file_path                                   
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} authentable ModelName"
    end
end

