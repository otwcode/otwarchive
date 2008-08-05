module Relevance; end
module Relevance; module ActiveRecord; end; end

module Relevance::ActiveRecord::MacroReflection
  module InstanceMethods
    [:has_many, :belongs_to, :has_one, :has_and_belongs_to_many].each do |macro_name|
      define_method("#{macro_name}?") do
        self.macro == macro_name
      end
    end
  end
end

ActiveRecord::Reflection::MacroReflection.class_eval {include Relevance::ActiveRecord::MacroReflection::InstanceMethods}
