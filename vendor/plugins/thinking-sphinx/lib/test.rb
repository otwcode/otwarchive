require 'thinking_sphinx'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'nullus_development',
  :username => 'nullus',
  :password => 'wossname',
  :host     => 'localhost'
)
ActiveRecord::Base.logger = Logger.new(STDERR)

class User < ActiveRecord::Base
  has_many :posts, :foreign_key => "created_by"
end

class Post < ActiveRecord::Base
  belongs_to :creator, :foreign_key => "created_by", :class_name => "User"
  belongs_to :updater, :foreign_key => "updated_by", :class_name => "User"
  belongs_to :topic
end

class Topic < ActiveRecord::Base
  belongs_to :creator, :foreign_key => "created_by", :class_name => "User"
  belongs_to :forum
  has_many :posts
end

class Forum < ActiveRecord::Base
  belongs_to :creator, :foreign_key => "created_by", :class_name => "User"
  has_many :topics
end

def index
  @index ||= ThinkingSphinx::Index.new(Topic) do
    indexes posts.content, :as => :posts
    indexes posts.creator.login, :as => :authors
    
    has :created_at
    has :id, :as => :topic_id
    has :forum_id
    has posts(:id), :as => :post_ids
    has posts.creator(:id), :as => :user_ids
    
    where "posts.created_at < NOW()"
  end
end