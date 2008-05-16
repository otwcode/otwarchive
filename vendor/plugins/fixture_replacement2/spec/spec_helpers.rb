module SpecHelperFunctions
  # We need this just so that the tests don't fail
  # when we are running the tests outside of a real rails project.
  # Otherwise, the tests would fail with a file not found error,
  # since db/example_data.rb is no where to be found
  def swap_out_require!
    Kernel.module_eval do
      
      # Thanks, Jay Fields:
      # http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
      require_method = instance_method(:require)

      define_method(:require) do |string|
        unless string == "/db/example_data.rb"
          require_method.bind(self).call(string)
        end
      end
    end
  end
  
  def setup_database_connection
    
    require 'rubygems'
    require 'sqlite3'
    require 'active_record'
    require 'active_support'
    
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do  
      create_table :users, :force => true do |t|
        t.column  :key,       :string
        t.column  :other_key, :string
        t.column  :gender_id, :integer
        t.column  :username,  :string
      end
      
      create_table :players, :force => true do |t|
        t.column :username, :string
        t.column :key, :string
      end

      create_table :genders, :force => true do |t|
        t.column  :sex, :string
      end

      create_table :aliens, :force => true do |t|
        t.column :gender_id, :string
      end

      create_table :admins, :force => true do |t|
        t.column :admin_status, :boolean
        t.column :name, :string
        t.column :username, :string
        t.column :key, :string
        t.column :other_key, :string
      end  

      create_table :items, :force => true do |t|
        t.column :category, :integer
        t.column :type, :string
        t.column :name, :string
      end

      create_table :categories, :force => true do |t|
        t.column :name, :string
      end
      
      create_table :subscribers, :force => true do |t|
        t.column :first_name, :string
      end
      
      create_table :subscriptions, :force => true do |t|
        t.column :name, :string
      end
      
      create_table :subscribers_subscriptions, :force => true, :id => false do |t|
        t.column :subscriber_id, :integer
        t.column :subscription_id, :integer
      end
    end
  end  
end




