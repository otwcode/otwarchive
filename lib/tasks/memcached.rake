namespace :memcached do

 # For example
 # WORKS="posted = 0" rake memcached:clear_work
 #
 desc "Clear memcached"
 task :expire_work_blurbs => :environment  do
  works=ENV['WORKS'] || 'id=1'
  Work.where(works).find_each do |work|
    puts "Clear memcached #{work.id}"
    Rails.cache.increment(work_blurb_tag_cache_key(work.id))
  end 
 end

end
