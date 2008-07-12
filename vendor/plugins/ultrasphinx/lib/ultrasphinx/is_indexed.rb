
require 'ultrasphinx'

module ActiveRecord
  class Base

=begin rdoc

The is_indexed method configures a model for indexing. Its parameters help generate SQL queries for Sphinx.

= Options

== Including regular fields

Use the <tt>:fields</tt> key.

Accepts an array of field names or field hashes. 
  :fields => [
    'created_at', 
    'title', 
    {:field => 'body', :as => 'description'},
    {:field => 'user_category', :facet => true, :as => 'category' }
  ]
  
To alias a field, pass a hash instead of a string and set the <tt>:as</tt> key. 

To allow faceting support on a text field, also pass a hash and set the <tt>:facet</tt> key to <tt>true</tt>. Faceting is off by default for text fields because there is some indexing overhead associated with it. Faceting is always on for numeric or date fields.

To allow sorting by a text field, also pass a hash and set the <tt>:sortable</tt> key to true. This is turned off by default for the same reason as above. Sorting is always on for numeric or date fields.

To apply an SQL function to a field before it is indexed, use the key <tt>:function_sql</tt>. Pass a string such as <tt>"REPLACE(?, '_', ' ')"</tt>. The table and column name for your field will be interpolated into the first <tt>?</tt> in the string.

Note that <tt>float</tt> fields are supported, but require Sphinx 0.98.

== Requiring conditions

Use the <tt>:conditions</tt> key.

SQL conditions, to scope which records are selected for indexing. Accepts a string. 

  :conditions => "created_at < NOW() AND deleted IS NOT NULL"
  
The <tt>:conditions</tt> key is especially useful if you delete records by marking them deleted rather than removing them from the database.

== Including a field from an association

Use the <tt>:include</tt> key.

Accepts an array of hashes. 

  :include => [{:association_name => 'category', :field => 'name', :as => 'category_name'}]

Each should contain an <tt>:association_name</tt> key (the association name for the included model), a <tt>:field</tt> key (the name of the field to include), and an optional <tt>:as</tt> key (what to name the field in the parent). 

<tt>:include</tt> hashes also accept their own <tt>:conditions</tt> key. You can use this  if you need custom WHERE conditions for this particular association (e.g, this JOIN).

The keys <tt>:facet</tt>, <tt>:sortable</tt>, <tt>:class_name</tt>, <tt>:association_sql</tt>, and <tt>:function_sql</tt> are also recognized.

== Concatenating several fields within one record

Use the <tt>:concatenate</tt> key (MySQL only).

Accepts an array of option hashes. 

To concatenate several fields within one record as a combined field, use a regular (or lateral) concatenation. Regular concatenations contain a <tt>:fields</tt> key (again, an array of field names), and a mandatory <tt>:as</tt> key (the name of the result of the concatenation). For example, to concatenate the <tt>title</tt> and <tt>body</tt> into one field called <tt>text</tt>: 
  :concatenate => [{:fields => ['title', 'body'], :as => 'text'}]
  
The keys <tt>:facet</tt>, <tt>:sortable</tt>, <tt>:conditions</tt>, <tt>:function_sql</tt>, <tt>:class_name</tt>, and <tt>:association_sql</tt>, are also recognized.

Lateral concatenations are implemented with CONCAT_WS on MySQL and with a stored procedure on PostgreSQL.

== Concatenating the same field from a set of associated records 

Also use the <tt>:concatenate</tt> key.

To concatenate one field from a set of associated records as a combined field in the parent record, use a group (or vertical) concatenation. A group concatenation should contain an <tt>:association_name</tt> key (the association name for the included model), a <tt>:field</tt> key (the field on the included model to concatenate), and an optional <tt>:as</tt> key (also the name of the result of the concatenation). For example, to concatenate all <tt>Post#body</tt> contents into the parent's <tt>responses</tt> field:
  :concatenate => [{:association_name => 'posts', :field => 'body', :as => 'responses'}]

The keys <tt>:facet</tt>, <tt>:sortable</tt>, <tt>:conditions</tt>, <tt>:function_sql</tt>, <tt>:class_name</tt>, and <tt>:association_sql</tt>, are also recognized.

Vertical concatenations are implemented with GROUP_CONCAT on MySQL and with an aggregate and a stored procedure on PostgreSQL.

== Custom joins

<tt>:include</tt> and <tt>:concatenate</tt> accept an <tt>:association_sql</tt> key. You can use this if you need to pass a custom JOIN string, for example, a double JOIN for a <tt>has_many :through</tt>). If <tt>:association_sql</tt> is present, the default JOIN for <tt>belongs_to</tt> will not be generated. 

Also, If you want to include a model that you don't have an actual ActiveRecord association for, you can use <tt>:association_sql</tt> combined with <tt>:class_name</tt> instead of <tt>:association_name</tt>. <tt>:class_name</tt> should be camelcase.

Ultrasphinx is not an object-relational mapper, and the association generation is intended to stay minimal--don't be afraid of <tt>:association_sql</tt>.

= Examples

== Complex configuration

Here's an example configuration using most of the options, taken from production code:

  class Story < ActiveRecord::Base  
    is_indexed :fields => [
        'title', 
        'published_at',
        {:field => 'author', :facet => true}
      ],
      :include => [
        {:association_name => 'category', :field => 'name', :as => 'category_name'}
      ],      
      :concatenate => [
        {:fields => ['title', 'long_description', 'short_description'], 
          :as => 'editorial'},
        {:association_name => 'pages', :field => 'body', :as => 'body'},
        {:association_name => 'comments', :field => 'body', :as => 'comments', 
          :conditions => "comments.item_type = '#{base_class}'"}
      ],
      :conditions => self.live_condition_string
  end  

Note how setting the <tt>:conditions</tt> on Comment is enough to configure a polymorphic <tt>has_many</tt>.

== Association scoping

A common use case is to only search records that belong to a particular parent model. Ultrasphinx configures Sphinx to support a <tt>:filters</tt> element on any date or numeric field, so any <tt>*_id</tt> fields you have will be filterable.

For example, say a Company <tt>has_many :users</tt> and each User <tt>has_many :articles</tt>. If you want to to filter Articles by Company, add <tt>company_id</tt> to the Article's <tt>is_indexed</tt> method. The best way is to grab it from the User association:

  class Article < ActiveRecord::Base 
     is_indexed :include => [{:association_name => 'users', :field => 'company_id'}]
  end
 
Now you can run:

 @search = Ultrasphinx::Search.new('something', 
   :filters => {'company_id' => 493})
 
If the associations weren't just <tt>has_many</tt> and <tt>belongs_to</tt>, you would need to use the <tt>:association_sql</tt> key to set up a custom JOIN. 

=end
  
    def self.is_indexed opts = {}    
      opts = HashWithIndifferentAccess.new(opts)
          
      opts.assert_valid_keys ['fields', 'concatenate', 'conditions', 'include']
      
      Array(opts['fields']).each do |entry|
        if entry.is_a? Hash
          entry.stringify_keys!
          entry.assert_valid_keys ['field', 'as', 'facet', 'function_sql', 'sortable']
        end
      end
      
      Array(opts['concatenate']).each do |entry|
        entry.stringify_keys!
        entry.assert_valid_keys ['class_name', 'association_name', 'conditions', 'field', 'as', 'fields', 'association_sql', 'facet', 'function_sql', 'sortable']
        raise Ultrasphinx::ConfigurationError, "You can't mix regular concat and group concats" if entry['fields'] and (entry['field'] or entry['class_name'] or entry['association_name'])
        raise Ultrasphinx::ConfigurationError, "Concatenations must specify an :as key" unless entry['as']
        raise Ultrasphinx::ConfigurationError, "Group concatenations must not have multiple fields" if entry['field'].is_a? Array
        raise Ultrasphinx::ConfigurationError, "Regular concatenations should have multiple fields" if entry['fields'] and !entry['fields'].is_a?(Array)
      end
      
      Array(opts['include']).each do |entry|
        entry.stringify_keys!
        entry.assert_valid_keys ['class_name', 'association_name', 'field', 'as', 'association_sql', 'facet', 'function_sql', 'sortable']
      end
      
      Ultrasphinx::MODEL_CONFIGURATION[self.name] = opts
    end
  end
end
