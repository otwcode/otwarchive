require 'streamlined/view'
require 'streamlined/helper'

class Streamlined::Column::Base
  include Streamlined::Helpers::FormHelper
  include ERB::Util
  
  attr_accessor :human_name, :link_to, :popup, :parent_model, :wrapper, :additional_column_pairs,
                :additional_includes, :filter_column, :help
  
  attr_with_default :human_name_explicitly_set, 'false'
  attr_with_default :read_only, 'false'
  attr_with_default :create_only, 'false'
  attr_with_default :update_only, 'false'
  attr_with_default :allow_html, 'false'
  attr_with_default :edit_in_list, 'true'
  attr_with_default :hide_if_unassigned, 'false'
  attr_with_default :unassigned_value, '"Unassigned"'
  attr_with_default :html_options, '{}'
  
  def human_name
    (@human_name.nil? || human_name_explicitly_set) ? @human_name : @human_name.titleize
  end
  
  def editable
    !(read_only || create_only) && edit_in_list
  end
  
  def model_underscore
    parent_model.name.underscore
  end
  
  def sort_column
    name
  end
  
  def form_field_id
    "#{model_underscore}_#{name_as_id}"
  end
  
  def name_as_id
    "#{name}_id"
  end
  
  def name_as_ids
    "#{name.to_s.singularize}_ids"
  end
  
  def belongs_to?
    false
  end
  
  def has_many?
    false
  end
  
  def active_record?
    false
  end
  
  def association?
    false
  end
  
  def addition?
    false
  end
  
  def unassigned_option
    [unassigned_value, nil]
  end
  
  def renderers
    metaclass = class <<self; self; end
    metaclass.public_instance_methods.grep(/render_/) - ["render_wrapper="]   
  end
  
  def render_wrapper=(block_or_view_method_name)
    if Proc === block_or_view_method_name
      wrap_renderers_with_proc(block_or_view_method_name)
    else
      wrap_renderers_with_view_method(block_or_view_method_name)
    end
  end
  
  def wrap_renderers_with_proc(block)
    metaclass = class <<self; self; end
    renderers.each do |renderer_name|
      metaclass.wrap_method(renderer_name, &block)
    end
  end
  
  def wrap_renderers_with_view_method(method_name)
    metaclass = class <<self; self; end
    renderers.each do |renderer_name|
      metaclass.wrap_method(renderer_name) {|meth,view,*args|
        view.method(method_name).call(meth,view,*args)
      }
    end
  end
  
  def is_required?
    column_required?(parent_model, name)
  end
  
  def set_attributes(hash)
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end
  end
  
  def render_td(view, item)
    if read_only
      result = render_td_show(view, item)
    else
      result = send("render_td_#{view.crud_context}", view, item)
    end
    wrap(result)
  end
  
  [:show, :edit, :list, :new].each do |meth|
    define_method("render_td_#{meth}") do |*args|
      "[TBD: render_td_#{meth} for #{self.class}]"
    end
  end
  
  def render_tr_show(view, item)
    if is_displayable_in_context?(view, item)
      x = Builder::XmlMarkup.new
      x.tr(:id => render_id(view, item)) do
        x.td(:class => "sl_show_label") do
          x.text!("#{human_name}:") 
        end
        x.td(:class => "sl_show_value") do
          x << render_td(view, item)
        end
      end
      x.target!
    else
      ""
    end
  end
  
  def render_content(view, item)
    content = item.send(self.name)    
    content = Streamlined.format_for_display(content)
    content = h(content) unless allow_html
    content = wrap_with_link(content, view, item)
    content = wrap_with_popup(content, view, item)
    content
  end
  
  # TODO: make a request_context that delegates to other bits
  def sort_image(context, view)
    if context.sort_column?(self)
      direction = context.sort_ascending? ? 'up' : 'down'
      view.image_tag("streamlined/arrow-#{direction}_16.png", {:height => '10px', :border => 0})
    else
      ''
    end
  end
  
  def render_th(view, context)
    x = Builder::XmlMarkup.new
    x.th(:class => "sortSelector", :scope => "col", :col => sort_column) do
      x << human_name
      x << sort_image(context,view)
    end
  end
  
  def render_id(view, item)
    case view.crud_context
    when :list
      "#{model_underscore}_#{item.id}_#{name}"
    else
      "sl_field_#{model_underscore}_#{name}"
    end
  end
  
  def render_tr_edit(view, item)
    x = Builder::XmlMarkup.new
    x.tr(:id => render_id(view, item)) do
      x.td(:class => 'sl_edit_label') do
        x.label(:for => "#{model_underscore}_#{name}") do
          x.text!(human_name)
          if mark_required?(item)
            x.span("*", :class => "required")
          end
        end
      end
      x.td(:class => 'sl_edit_value') do
        x << render_td(view, item)
      end
    end
  end
  
  def append_help(html)
    x = Builder::XmlMarkup.new
    x.div(:class => "streamlined_help") { x << help } unless help.blank?
    html << x.target!
  end
  
  def is_displayable_in_context?(view, item)
    # TODO: extract this nastiness into a class?  Only if we see one more need for objectified crud contexts!!!!!!
    column_answer = case view.crud_context
    when :new
      !(self.read_only || self.update_only)
    when :show, :list
      !(hide_if_unassigned && item.send(self.name).blank?)
    when :edit
      !(self.read_only || self.create_only)
    end
    instance_answer = item.respond_to?(:should_display_column_in_context?) ?
                      item.should_display_column_in_context?(self, view) : true
    column_answer && instance_answer
  end
  
  # TODO: eliminate the helper version of this
  def relationship_div_id(name, item, class_name = '', in_window = false)
    fragment = edit_view ? edit_view.id_fragment : "temp"
    "#{fragment}::#{name}::#{item.id}::#{class_name}#{'::win' if in_window}"
  end
  
  # Should this column be marked required for this item?
  def mark_required?(item)
    ui = Streamlined::ui_for(item.class)
		ui.mark_required_fields && is_required?
	end
  
  def div_wrapper(id, &block)
    "<div id=\"#{id}\">#{yield}</div>"
  end
  
  def wrap(content)
    wrapper && wrapper.respond_to?(:call) ? wrapper.call(content) : content
  end
  
  def wrap_with_link(content, view, item) 
    if link_to
      if link_to.instance_of? Array
        link_to[0] = link_to[0].merge(:id=>item) unless link_to[0].has_key?(:id)
        link_args = link_to
      else
        link_args = link_to.has_key?(:id) ? link_to : link_to.merge(:id=>item.id)
      end
      view.wrap_with_link(link_args) { content }
    else
      content
    end
  end
  
  def wrap_with_popup(content, view, item)
    if popup
      popup_args = popup.has_key?(:id) ? popup : popup.merge(:id => item)
      "<span class=\"sl-popup\">#{view.invisible_link_to(popup_args)}#{content}</span>"
    else
      content
    end
  end
end