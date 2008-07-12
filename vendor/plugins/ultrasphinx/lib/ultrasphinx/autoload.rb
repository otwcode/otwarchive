
require 'initializer'

class Rails::Initializer

  def after_initialize_with_ultrasphinx_configuration
    after_initialize_without_ultrasphinx_configuration
    Ultrasphinx::Configure.load_constants
    Ultrasphinx.verify_database_name
  end     
  
  alias_method_chain :after_initialize, :ultrasphinx_configuration
end
