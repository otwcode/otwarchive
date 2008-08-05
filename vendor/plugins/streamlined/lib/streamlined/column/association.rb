# Currently available Views:
# * :membership => simple scrollable list of checkboxes.  DEFAULT for n_to_many
# * :inset_table => full table view inserted into current table
# * :window => same table from :inset_table but displayed in a window
# * :filter_select => like :membership, but with an auto-filter text box and two checkbox lists, one for selected and one for unselected items
# * :polymorphic_membership => like :membership, but for polymorphic associations.  DEPRECATED: :membership will be made to handle this case.
# * :select => drop down box.  DEFAULT FOR n_to_one
#
# Currently available Summaries:
# * :count => number of associated items. DEFAULT FOR n_to_many
# * :name => name of the associated item. DEFAULT FOR n_to_one
# * :list => list of data from specified :fields
# * :sum => sum of values from a specific column of the associated items

# Wrapper around ActiveRecord::Association.  Keeps track of the underlying association, the View definition and the Summary definition.
class Streamlined::Column::Association < Streamlined::Column::Base
  attr_reader :underlying_association, :edit_view, :show_view
  attr_accessor :options_for_select
  attr_with_default :quick_add, 'true'
  delegates :name, :class_name, :to => :underlying_association
  delegates :belongs_to?, :has_many?, :has_and_belongs_to_many?, :primary_key_name, :to => :underlying_association 
  
  def initialize(assoc, parent_model, edit, show)
    @underlying_association = assoc
    @parent_model = parent_model
    self.edit_view = edit
    self.show_view = show
    @human_name = name.to_s.humanize
  end
  
  def table_name
    name.to_s.tableize
  end
  
  def association?
    true
  end
  
  def filterable?
    !filter_column.blank?
  end

  def edit_view=(opts)
    @edit_view = case(opts)
    when(Symbol)
      Streamlined::View::EditViews.create_relationship(opts)
    when(Array)
      Streamlined::View::EditViews.create_relationship(*opts)
    when(Streamlined::View::Base)
      opts
    else
      raise ArgumentError, opts.class.to_s
    end
  end
  
  def show_view=(opts)
    @show_view = case(opts)
    when(Symbol)
      Streamlined::View::ShowViews.create_summary(opts)
    when(Array)
      Streamlined::View::ShowViews.create_summary(*opts)
    when(Streamlined::View::Base)
      opts
    else
      raise ArgumentError, opts.class.to_s
    end
  end

  # Returns a list of all the classes that can be used to satisfy this relationship.  In a polymorphic relationship, it is the union 
  # of every type that is configured :as the relationship type.  For direct associations, it is the listed type of the relationship.      
  def associables             
    return [@underlying_association.class_name.constantize] unless @underlying_association.options[:polymorphic]
    results = []
    ObjectSpace.each_object(Class) do |klass|
      results << klass if klass.ancestors.include?(ActiveRecord::Base) && klass.reflect_on_all_associations.collect {|a| a.options[:as]}.include?(@underlying_association.name)
    end
    return results
  end
  
  # Returns an array of all items that can be selected for this association.
  def items_for_select
    klass = class_name.constantize
    if associables.size == 1
      klass.find(:all)
    else
      items = {}
      associables.each { |klass| items[klass.name] = klass.find(:all) }
      items
    end
  end
  
  def render_td_show(view, item)
    view.render(:file => show_view.partial, :use_full_path => false,
                :locals => { :item => item, :relationship => self, :streamlined_def => show_view })
  end
  
  def render_td_list(view, item)
    id = relationship_div_id(name, item, class_name)
    content = render_td_show(view, item)
    content = wrap_with_link(content, view, item)
    content = div_wrapper(id) { content }
    content += view.link_to_function("Edit", "Streamlined.Relationships." <<
      "open_relationship('#{id}', this, '/#{view.controller_path}')") if editable
    content
  end

  # TODO: moved STREAMLINED_NONE smarts into a separate component
  def render_select_with_streamlined_none(view, object, method, choices, options, html_options)
    normal_select = view.select(object, method, choices, options, html_options)
    name = "#{object}[#{method}][]"
    hidden_none_select = view.hidden_field_tag(name, STREAMLINED_SELECT_NONE)
    normal_select + hidden_none_select
  end
  
  def render_td_edit(view, item)
    result = "[TBD: editable associations]"
    case
    when has_many?, has_and_belongs_to_many?
      choices = options_for_select ? custom_options_for_select(view) : standard_options_for_select
      selected_choices = item.send(name).collect {|e| e.id} if item.send(name)
      result = Streamlined::Components::Select.render do |s|
        s.view = view
        s.object = model_underscore
        s.method = name
        s.choices = choices
        s.options = {:selected => selected_choices }
        s.html_options = {:size => 5, :multiple => true}
      end
    when belongs_to?
      choices = options_for_select ? custom_options_for_select(view) : standard_options_for_select
      choices.unshift(unassigned_option) if column_can_be_unassigned?(parent_model, name)
      selected_choice = item.send(name).id if item.send(name)
      result = view.select(model_underscore, primary_key_name, choices, { :selected => selected_choice }, html_options)
      result += render_quick_add(view) if should_render_quick_add?(view)
    end
    append_help(result)
  end 
  alias :render_td_new :render_td_edit
  
  def render_quick_add(view)
    url = view.url_for(:action => 'quick_add', :model_class_name => class_name, :select_id => form_field_id)
    image = view.image_tag('streamlined/add_16.png', 
                           :id => "sl_qa_#{parent_model.class_name.underscore}_#{name}", :alt => 'Quick Add',
                           :title => 'Quick Add', :border => '0', :hspace => 2, :class => "sl_quick_add_link")
    view.link_to image, url
  end
  
  def should_render_quick_add?(view)
    quick_add && belongs_to? && view.params[:action] != 'quick_add'
  end
  
  private
  def custom_options_for_select(view)
    assoc_class = class_name.constantize
    arity = assoc_class.method(options_for_select).arity
    if arity == 0
      assoc_class.send(options_for_select)
    else
      streamlined_item = view.instance_variable_get("@streamlined_item")
      assoc_class.send(options_for_select, streamlined_item)
    end
  end
  
  def standard_options_for_select
    items_for_select.collect { |e| [e.streamlined_name(edit_view.fields, edit_view.separator), e.id] }
  end
end
