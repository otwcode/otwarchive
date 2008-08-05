# Streamlined
# (c) 2005-2008 Relevance, Inc.. (http://thinkrelevance.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlinedframework.org/

# TODO: Arguably belongs to Streamlined::Controller::Context
module Streamlined; end
require 'streamlined/reflection'

# Model-specific UI. Each Model class will have a parallel model_ui.rb in the app/streamlined
# directory for managing the views. For example, if your application has two models, <tt>User</tt>
# and <tt>Role</tt> (in <tt>app/models/user.rb</tt> and <tt>app/models/role.rb)</tt>, your
# Streamlined application would also have <tt>app/streamlined/user_ui.rb</tt> and
# <tt>app/streamlined/role_ui.rb</tt>, containing the classes <tt>UserUI</tt> and <tt>RoleUI</tt>.
#
# Inside your model_ui.rb file you should specify which model you are defining a UI for and
# include your column declarations and other view options. The syntax looks like this:
#
#   Streamlined.ui_for(Model) do
#     list_columns ...
#     pagination ...
#     ...
#   end
#
# See the Streamlined wiki (http://trac.streamlinedframework.org) for more information about
# the declarations available to you inside the UI definition.
#
class Streamlined::UI
  include Streamlined::Reflection
  attr_accessor :model
  declarative_scalar :pagination, :default => true
  declarative_scalar :table_row_buttons, :default => true
  declarative_scalar :quick_delete_button, :default => true
  declarative_scalar :quick_edit_button, :default => true
  declarative_scalar :quick_new_button, :default => true
  declarative_scalar :quick_show_button, :default => true
  declarative_scalar :table_filter, :default => {:show => true, :case_sensitive => true}
  declarative_scalar :read_only, :default => false
  declarative_scalar :new_submit_button, :default => {:ajax => true}
  declarative_scalar :edit_submit_button, :default => {:ajax => true}
  declarative_scalar :mark_required_fields, :default => true
  declarative_scalar :header_partials, :default => {}
  declarative_scalar :after_header_partials, :default => {}
  declarative_scalar :footer_partials, :default => {}
  declarative_scalar :style_classes, :default => {}   
  declarative_scalar :display_formats, :default => {}
  declarative_scalar :default_order_options, :default => {},
                     :writer => Proc.new { |x| x.is_a?(Hash) ? x : {:order => x}}
  # Export definitions
  declarative_attribute '*args', :exporters, :default => [:enhanced_xml_file, :xml_stylesheet, :enhanced_xml, :xml, :csv, :json, :yaml]
  declarative_scalar              :allow_full_download,        :default => true
  declarative_scalar              :default_full_download,      :default => true
  declarative_scalar              :default_separator,          :default => ','
  declarative_scalar              :default_skip_header,        :default => false
  declarative_scalar              :default_exporter,           :default => :enhanced_xml_file
  declarative_attribute '*args',  :default_deselected_columns, :default => []
  
  def initialize(model, &blk)
    @model = String === model ? model.constantize : model
    self.instance_eval(&blk) if block_given?
  end
  
  def inherited(subclass) #:nodoc:
    # subclasses inherit some settings from superclass
    subclass.table_row_buttons(self.table_row_buttons)
    subclass.quick_delete_button(self.quick_delete_button)
    subclass.quick_edit_button(self.quick_edit_button)
    subclass.quick_new_button(self.quick_new_button)
    subclass.quick_show_button(self.quick_show_button)
    subclass.exporters(*self.exporters)
  end      
  
  def style_class_for(crud_context, table_context, item)
    crud_classes = style_classes[crud_context]
    style_class = crud_classes[table_context] if crud_classes
    style_class.respond_to?(:call) ? style_class.call(item) : style_class
  end

  # Defines the columns that should be visible to the user at runtime.  Takes an array
  # of column names.  For example:
  # 
  #   user_columns :login, :first_name, :last_name
  # 
  # Column order is reflected in the view. By default, user_columns excludes:
  # 
  # * Any field whose name ends in "_at" (Rails-managed timestamp field)
  # * Any field whose name ends in "_on" (Rails-managed timestamp field)
  # * Any field whose name ends in "_id" (foreign key)
  # * The "position" field (Rails-managed ordering column)
  # * The "lock_version" field (Rails-managed optimistic concurrency)
  # * The "password_hash" field (if using a hashed-password strategy)
  def user_columns(*args)
    if args.size > 0
      convert_args_to_columns(:@user_columns, *args)
    else
      @user_columns ||= all_columns.reject do |v|
        v.name.to_s.match /(_at|_on|position|lock_version|_id|password_hash|id)$/
      end
    end
  end

  def override_columns(name, *args) #:nodoc:
    if args.size > 0
      convert_args_to_columns(name, *args)
    else
      instance_variable_get(name) || user_columns
    end
  end
  
  def convert_args_to_columns(name, *args) #:nodoc
    instance_variable_set(name, [])
    args.each do |arg|
      if Hash === arg
        instance_variable_get(name).last.set_attributes(arg)
        current_column = instance_variable_get(name).last
        current_column.set_attributes(arg)
        current_column.human_name_explicitly_set = true if arg[:human_name]
      else
        col = column(arg)
        if col.nil?
          col = Streamlined::Column::Addition.new(arg, model)
        end
        # @user_columns not dup'ed so they act as default for other groups
        col = col.dup unless name.to_s == "@user_columns"
        instance_variable_get(name) << col
      end
    end
  end
  
  # Defines the columns that should be visible when the user clicks the
  # "Show" button at runtime.  Takes an array of column names.  For example:
  #
  #   show_columns :login, :first_name, :last_name
  #
  # Column order is reflected in the view. show_columns uses the same
  # default column exclusions as user_columns.
  def show_columns(*args)
    override_columns(:@show_columns, *args)
  end
  
  # Defines the columns that should be editable by the user at runtime.
  # Takes an array of column names.  For example:
  #
  #   edit_columns :login, :first_name, :last_name
  #
  # Column order is reflected in the view. edit_columns uses the same
  # default column exclusions as user_columns.
  def edit_columns(*args)
    override_columns(:@edit_columns, *args)
  end
  
  # Alias for user_columns (?)
  def list_columns(*args)
    override_columns(:@list_columns, *args)
  end

  def id_fragment(relationship, crud_type)
    relationships[relationship.name].send("#{crud_type}_view").id_fragment  
  end
  
  def quick_add_columns(*args)
    if args.size > 0
      convert_args_to_columns(:@quick_add_columns, *args)
    else
      @quick_add_columns ||= user_columns.reject do |c|
        c.is_a?(Streamlined::Column::Addition)
      end
    end
  end
  
  # Creates a custom group of columns that doesn't override any of the standard
  # sets of columns. The only time this would be useful is if a custom view
  # needed access to Streamlined's nifty renderers outside of the traditional
  # list, show, edit, etc. column groups. For example:
  #
  #   custom_columns_group :group_name, :first_name, :last_name
  #
  # This code would create an instance variable called @group_name that would
  # contain the first_name and last_name columns. The group could then be
  # accessed inside a custom view this way:
  #
  #   <% for column in custom_columns_group(:group_name) %>
  #     ...
  #   <% end %>
  #
  def custom_columns_group(name, *args)
    name = "@#{name}".to_sym
    args.size > 0 ? convert_args_to_columns(name, *args) : instance_variable_get(name)
  end
  
  def has_columns_group?(name)
    instance_variable_get("@#{name}")
  end
  
  def has_sortable_column?(name)
    list_columns.map(&:name).member?(name.to_s)
  end
  
  def column(name, options={})
    col = send("#{options[:crud_context]}_columns").find {|col| col.name.to_s == name.to_s} if options[:crud_context]
    col ||= scalars[name] || relationships[name] || delegations[name] || additions[name]
    col
  end
  
  def sort_models(models, column)
    raise SecurityError, "Invalid sort column name: #{column}" unless has_sortable_column?(column)
    models.sort! {|a,b| a.send(column.to_sym).to_s <=> b.send(column.to_sym).to_s}
  end
  
  def scalars
    @scalars ||= reflect_on_scalars
  end
  
  def additions
    @additions ||= reflect_on_additions
  end
  
  def relationships
    @relationships ||= reflect_on_relationships
  end
  
  def delegations
    @delegations ||= reflect_on_delegates
  end
  
  def all_columns
    @all_columns ||= (scalars.values + additions.values + relationships.values + delegations.values)
  end
  
  def conditions_by_like_with_associations(value)
    column_pairs = filterable_columns.collect { |c| "#{c.table_name}.#{c.filter_column}" }
    column_pairs += columns_with_additional_column_pairs.collect(&:additional_column_pairs)
    conditions = column_pairs.collect { |c| sql_pair(c, value) }
    conditions.join(" OR ")
  end
  
  def sql_pair(column, value)
    quoted_value = ActiveRecord::Base.connection.quote("%#{value}%")
    case_sensitive_filtering? ? "#{column} LIKE #{quoted_value}" : "UPPER(#{column}) LIKE UPPER(#{quoted_value})"
  end
  
  def show_table_filter?
    table_filter.is_a?(Hash) ? table_filter[:show] : table_filter
  end
  
  def case_sensitive_filtering?
    table_filter[:case_sensitive] if table_filter.is_a?(Hash)
  end
  
  def filterable_columns
    list_columns.select { |c| !c.addition? && c.filterable? }
  end
  
  def filterable_associations
    list_columns.select { |c| c.association? && c.filterable? }.collect(&:name)
  end
  
  def columns_with_additional_column_pairs
    list_columns.select { |c| c.additional_column_pairs != nil }
  end
  
  def additional_includes
    list_columns.select { |c| c.additional_includes != nil }.collect(&:additional_includes).flatten
  end

  def displays_exporter?(exporter)
    if exporters.is_a?(Array)
      exporters.include?(exporter)
    else
      exporters == exporter
    end
  end 

  def default_deselected_column?(column)
    if default_deselected_columns.is_a?(Array)
      default_deselected_columns.include?(column)
    else
      default_deselected_columns == column
    end
  end 

  def default_exporter?(exporter)
    default = displays_exporter?(default_exporter) ? default_exporter : Array(exporters).first
    default == exporter
  end 

  # Used as the form labels as well as the parameters passed to Streamlined::Controller::CrudMethods
  def export_labels
    @export_labels ||= {:enhanced_xml_file  => '&nbsp;Enhanced&nbsp;XML&nbsp;To&nbsp;File',
                        :xml_stylesheet     => '&nbsp;XML&nbsp;Stylesheet',
                        :enhanced_xml       => '&nbsp;Enhanced&nbsp;XML',
                        :xml                => '&nbsp;xml',
                        :csv                => '&nbsp;csv',
                        :json               => '&nbsp;json',
                        :yaml               => '&nbsp;yaml'
                       }
  end
end
require 'streamlined/ui/deprecated'
