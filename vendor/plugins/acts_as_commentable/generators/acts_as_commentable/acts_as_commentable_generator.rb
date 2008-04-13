class ActsAsCommentableGenerator < Rails::Generator::Base
  def manifest
    record do |m|  
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
            :migration_name => "CreateComments"
          }, :migration_file_name => 'create_comments'                                   
    end
  end

  protected
    def banner
      "Usage: #{$0} acts_as_commentable"
    end                
end
