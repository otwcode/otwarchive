require 'nested_has_many_through'

ActiveRecord::Associations::HasManyThroughAssociation.send :include, NestedHasManyThrough::Association
ActiveRecord::Reflection::AssociationReflection.send :include, NestedHasManyThrough::Reflection