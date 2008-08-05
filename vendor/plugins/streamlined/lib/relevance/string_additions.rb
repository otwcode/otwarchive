module Relevance; end
module Relevance::StringAdditions
  # preferred over constantize where failure should be unexceptional
  def to_const(failval=false)
    components = sub(/^::/,'').split('::')
    components.inject(Object) do |c,n|
      return failval unless c.const_defined?(n)
      c.const_get(n) 
    end
  end
  
  # convert anything to a valid Ruby variable name
  def variableize
    underscore.gsub('/','_')
  end
end

String.class_eval {include Relevance::StringAdditions}
