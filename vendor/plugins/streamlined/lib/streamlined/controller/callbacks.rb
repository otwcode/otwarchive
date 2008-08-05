module Streamlined::Controller::Callbacks  
  private

  def current_before_callback(action)
    self.class.callbacks["before_#{action}".to_sym]
  end
  
  def execute_before_callback(action)
    callback = current_before_callback(action)
    return self.send(callback) if callback.is_a?(Symbol)
    self.instance_eval(&callback)
  end
  
  def execute(action)
    result = execute_before_callback(action) if current_before_callback(action)
    yield unless result == false
  end
  
  def execute_before_create_and_yield(&proc)
    execute(:create, &proc)
  end

  def execute_before_update_and_yield(&proc)
    execute(:update, &proc)
  end

end
  
