%w(acts_as_commentable commentable_entity comment_methods).each do |file|
  require "plugins/acts_as_commentable/#{file}"
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Commentable
