# require 'acts_as_commentable'
%w(acts_as_commentable commentable_entity comment_methods).each do |file|
  require file
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::Commentable
