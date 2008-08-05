require 'streamlined/view'
module Streamlined; end
module Streamlined::Reflection
  def reflect_on_scalars
    scalars = model.columns.inject(HashWithIndifferentAccess.new) do |h,v|
      h[v.name] = Streamlined::Column::ActiveRecord.new(v, model)
      h
    end
  end

  def reflect_on_additions
    additions = HashWithIndifferentAccess.new
    if Object.const_defined?(model.name + "Additions")
      Class.class_eval(model.name + "Additions").instance_methods(false).each do |meth|
        additions[meth] = Streamlined::Column::Addition.new(meth, model)
      end
    end
    additions
  end

  def reflect_on_relationships
    relationships = HashWithIndifferentAccess.new
      model.reflect_on_all_associations.each do |assoc|
        rel = assoc.name
        relationships[rel] = create_relationship(rel) unless relationships[rel]
      end
    relationships
  end
  
  def reflect_on_delegates
    delegates = HashWithIndifferentAccess.new
    if model.respond_to?(:delegate_targets) && model.delegate_targets
      model.delegate_targets.each do |target|
        if has_assocation_or_aggregation?(model, target)
          ar_assoc = model.reflect_on_association(target)
          ui = Streamlined.ui_for(ar_assoc.class_name)
          ui.all_columns.each {|col| 
            delegates[col.name] = col.dup
          }
        end
      end
    end
    delegates
  end
  
  private
  
  def has_assocation_or_aggregation?(model, target_name)
    model.reflections.keys.include?(target_name)
  end
  
  def create_relationship(rel)
    association = model.reflect_on_association(rel)
    raise Exception, "STREAMLINED ERROR: No association '#{rel}' on class #{model}." unless association
    options = define_association(association)
    Streamlined::Column::Association.new(association, model, *options)
  end

  # TODO: move defaults down into association class
  # Used to define the default relationship declarations for each relationship in the model.
  def define_association(assoc, options = {:view => {}, :summary => {}})
    return {:summary => :none} if options[:summary] == :none
    case assoc.macro
    when :has_one, :belongs_to
      if assoc.options[:polymorphic]
        [:polymorphic_select, :name]
      else
        [:select, :name]
      end
    when :has_many, :has_and_belongs_to_many
      if assoc.options[:polymorphic]
        [:polymorphic_membership, :count]
      else
        [:membership, :count]
      end           
    end
  end  
    

end
