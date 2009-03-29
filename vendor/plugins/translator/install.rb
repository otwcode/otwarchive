unless Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 2
  raise "This version of Translator requires Rails 2.2 or higher."
end

#puts IO.read(File.join(File.dirname(__FILE__), 'README.textile'))
