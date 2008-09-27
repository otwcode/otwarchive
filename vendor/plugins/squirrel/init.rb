require File.dirname(__FILE__) + '/lib/squirrel.rb'
class << ActiveRecord::Base
  include Squirrel::Hook
end

if defined?(ActiveRecord::NamedScope::Scope)
  class ActiveRecord::NamedScope::Scope
    include Squirrel::NamedScopeHook
  end
end

[ ActiveRecord::Associations::HasManyAssociation,
  ActiveRecord::Associations::HasAndBelongsToManyAssociation,
  ActiveRecord::Associations::HasManyThroughAssociation
].each do |association_class|
  association_class.send(:include, Squirrel::Hook)
end
