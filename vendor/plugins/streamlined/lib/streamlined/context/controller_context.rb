# per controller context, kept for the lifetime of the controller class
# and made available via delegation to controllers and views
class Streamlined::Context::ControllerContext
  attr_accessor :ui_model_name, :ui_context
             
  def initialize(ui_model_name)
    streamlined_ui(ui_model_name)
  end
                        
  def self.delegates
    [:model_name,
     :model, 
     :model_symbol, 
     :model_table, 
     :model_underscore, 
     :model_ui,  
     :streamlined_ui]
  end
              
  def model
    Class.class_eval(model_name)
  end
  
  def model_symbol
    Inflector.underscore(model_name).to_sym
  end
  
  def model_table
    Inflector.tableize(model_name)
  end
  
  def model_underscore
    Inflector.underscore(model_name)
  end
    
  def model_ui
    Streamlined.ui_for(ui_model_name, :context => ui_context)
  end  

  def model_name
    ui_model_name
  end
  
  def streamlined_ui(ui_model_name, ui_context = nil, &blk)
    @ui_model_name = ui_model_name.to_s
    @ui_context = ui_context
    model_ui.instance_eval(&blk) if block_given?
  end
  
end