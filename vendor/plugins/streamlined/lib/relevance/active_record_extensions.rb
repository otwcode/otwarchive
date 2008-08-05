# Streamlined
# (c) 2005-2008 Relevance, Inc.. (http://thinkrelevance.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlinedframework.org/
#
# Adds several utility methods to ActiveRecord::Base for supporting view columns/
module Relevance; module ActiveRecordExtensions; end; end

module Relevance::ActiveRecordExtensions::ClassMethods
  
  def user_columns
    self.content_columns.find_all do |d|
      !d.name.match /(_at|_on|position|lock_version|_id|password_hash)$/
    end
  end
  
  def find_by_like(value, *columns)
    self.find(:all, :conditions=>conditions_by_like(value, *columns))
  end
  
  def find_by_criteria(template)
    conditions = conditions_by_criteria(template)
    if conditions.blank?
      self.find(:all)
    else 
      self.find(:all, :conditions=>conditions)
    end
  end
  
  def conditions_by_like(value, *columns)
    columns = self.user_columns if columns.size==0
    columns = columns[0] if columns[0].kind_of?(Array)
    # the conditions local variable is necessary for rcov to see this as covered
    conditions = columns.map {|c|
      c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column
      "#{c} LIKE " + ActiveRecord::Base.connection.quote("%%#{value}%%")
    }
    conditions.join(" OR ")
  end
  
  def conditions_by_criteria(template)
    attrs = template.class.columns.map &:name
    vals = []
    attrs.each {|a| vals << "#{a} LIKE " + ActiveRecord::Base.connection.quote("%%#{template.send(a)}%%") if !template.send(a).blank? && a != 'id' && a != 'lock_version' }
    vals.join(" AND ")
  end
  
  # Valid options:
  #  exclude_has_many_throughs = pass in true to not pull by :through has_manies -- by default they will be returned
  def has_manies(options = {})
    options.assert_valid_keys(:exclude_has_many_throughs)
    self.reflect_on_all_associations.select do |assoc|
      result = (assoc.has_many? || assoc.has_and_belongs_to_many?) 
      if options[:exclude_has_many_throughs]
        result && !assoc.options.include?(:through)
      else
        result
      end
    end
  end
  
  def has_ones
    self.reflect_on_all_associations.select {|x| x.has_one? || x.belongs_to?}
  end

  def delegate_target_associations
    self.delegate_targets.inject([]) do |acc, dt|
      assoc = self.reflect_on_association(dt)
      acc << assoc if assoc
      acc
    end
  end

end
  
module Relevance::ActiveRecordExtensions::InstanceMethods
  def streamlined_name(options = nil, separator = ':')
    if options
      options.map {|x| self.send(x)}.join(separator)
    else
      return self.name if self.respond_to?(:name) && self.method(:name).arity == 0
      return self.title if self.respond_to?(:title) && self.method(:title).arity == 0
      return self.id
    end
  end
  
  def streamlined_css_id
    "#{self.class.name.downcase}_#{self.id}"
  end
end
  
ActiveRecord::Base.send(:extend, Relevance::ActiveRecordExtensions::ClassMethods)
ActiveRecord::Base.send(:include, Relevance::ActiveRecordExtensions::InstanceMethods)
