require 'tsort'
require 'set'

class Graph < Hash
  include TSort

  alias tsort_each_node each_key

  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

def children(model)
  Set.new.tap do |children|
    model.reflect_on_all_associations.each do |association|
      next unless [:has_many, :has_one].include?(association.macro)
      next if association.options[:through]

      children << association.klass
    end
  end
end

Dir.glob('app/models/**/*.rb') do |model|
  load model
end

graph = Graph.new
ActiveRecord::Base.descendants.each do |model|
  graph[model] = children(model) unless model.abstract_class?
end

graph.tsort.reverse_each do |klass|
  puts klass.name
end
