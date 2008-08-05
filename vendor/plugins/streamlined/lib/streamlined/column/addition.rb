class Streamlined::Column::Addition < Streamlined::Column::Base
  attr_accessor :name, :sort_column

  def initialize(sym, parent_model)
    @name = sym.to_s
    @human_name = sym.to_s.humanize
    @read_only = true
    @parent_model = parent_model
  end
  
  def addition?
    true
  end

  # Array#== calls this
  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class === o
    return name.eql?(o.name)
  end
  
  def sort_column
    @sort_column.blank? ? name : @sort_column
  end
  
  def render_td_show(view, item)
    render_content(view, item)
  end
end
