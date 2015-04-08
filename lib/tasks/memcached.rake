namespace :memcached do

 # For example
 # WORKS="posted = 0" rake memcached:clear_work
 #
 desc "Clear memcached"
 task :clear_work => :environment  do
  works=ENV['WORKS'] || 'id=1'
  Work.where(works).find_each {
    |work|
    puts "Clear memcached #{work.id}"
    %w( nowarn showwarn ).each {
      |warn|
      %w( nofreeform showfreeform ).each {
        |freeform|
         Rails.cache.delete "#{work.cache_key}-#{warn}-#{freeform}-v3"
      }
    }
   }
 end

end
