namespace :memcached do

 # For example
 # WORKS="posted = 0" rake memcached:clear_work
 #
 desc "Clear memcached"
 task :expire_work_blurbs => :environment  do
  works=ENV['WORKS'] || 'id=1'
  Work.where(works).find_each do |work|
    puts "Clear memcached #{work.id}"
    %w( nowarn showwarn ).each do |warn|
      %w( nofreeform showfreeform ).each do |freeform|
         Rails.cache.delete "#{work.cache_key}-#{warn}-#{freeform}-v6"
      end 
    end 
  end 
 end

end
