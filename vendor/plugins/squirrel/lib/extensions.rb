class Hash
  def merge_tree other
    self.dup.merge_tree! other
  end
  
  def merge_tree! other
    other.each do |key, value|
      if self[key].is_a?(Hash) && value.is_a?(Hash)
        self[key] = self[key].merge_tree(value)
      else
        self[key] = value
      end
    end
    self
  end
end

module ActiveRecord #:nodoc: all
  module Associations
    module ClassMethods
      class JoinDependency
        class JoinAssociation
          def ancestry #:doc
            [ parent.ancestry, reflection.name ].flatten.compact
          end
        end
        class JoinBase
          def ancestry
            nil
          end
        end
      end
    end
  end
end

