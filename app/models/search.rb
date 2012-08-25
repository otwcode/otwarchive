class Search < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name
  validates_presence_of :options
  
  serialize :options, Hash
  
  def self.serialized_options(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.options || {})[:#{method_name}]
        end
        def #{method_name}=(value)
          self.options ||= {}
          self.options[:#{method_name}] = value
        end
      "
    end
  end
  
end
