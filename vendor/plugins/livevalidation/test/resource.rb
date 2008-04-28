ActiveRecord::Base.class_eval do
  alias_method :save, :valid?
  def self.columns() @columns ||= []; end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type, null)
  end
end

class Resource < ActiveRecord::Base
  column :id, :integer
  column :name, :string
  column :amount, :integer
  column :conditions, :boolean
  
  attr_accessor :password
end
