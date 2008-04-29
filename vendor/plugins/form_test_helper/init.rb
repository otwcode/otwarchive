if RAILS_ENV == 'test'

  dir = File.expand_path(File.dirname(__FILE__))
  Dir[dir + "/lib/*.rb"].each do |file|
    require file
  end

  Test::Unit::TestCase.class_eval do
      include FormTestHelper::LinkMethods
      include FormTestHelper::FormMethods
      include FormTestHelper::RequestMethods    
  end

  # I have to include FormTestHelper this way or it loads from gems and not vendor:
  module ActionController::Integration
    class Session
      include FormTestHelper::LinkMethods
      include FormTestHelper::FormMethods
      include FormTestHelper::RequestMethods
    end
  end

end