module Streamlined; end
module Streamlined::Breadcrumb
  def node_for(crud_context, instance)
    class_name = instance.class.to_s
    case crud_context
      when :list
        Proc.new { link_to class_name.titleize.pluralize, :controller => class_name.underscore.pluralize,
          :action => "list" }
      when :show
        Proc.new { link_to instance.name, :controller => class_name.underscore.pluralize,
          :action => "show", :id => instance.id }
    end
  end
  
  module Nodes
    HOME = Proc.new { link_to("Home", "/") }
    LIST_LINKED = Proc.new { link_to(model_name.titleize.pluralize, :action => "list") }
    LIST_UNLINKED = Proc.new { model_name.titleize.pluralize }
    CRUD_CONTEXT = Proc.new { header_text(prefix_for_crud_context) }
  end
end
