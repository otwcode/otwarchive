class User < ActiveRecord::Base
  belongs_to :gender  
  validates_presence_of :key
end

class Player < ActiveRecord::Base
end

class Alien < ActiveRecord::Base
  belongs_to :gender
end

class Admin < ActiveRecord::Base
  attr_protected :admin_status
end

class Gender < ActiveRecord::Base; end
class Actress < ActiveRecord::Base; end

class Item < ActiveRecord::Base
  belongs_to :category
end

class Writing < Item; end

class Category < ActiveRecord::Base
  has_many :items
end

class Subscriber < ActiveRecord::Base
  has_and_belongs_to_many :subscriptions
end

class Subscription < ActiveRecord::Base
  has_and_belongs_to_many :subscribers
end