require 'rbconfig'

class FixtureReplacementGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      script_options     = {:chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }

      m.directory 'db'
      m.template  'example_data.erb',                'db/example_data.rb'
    end
  end

end
