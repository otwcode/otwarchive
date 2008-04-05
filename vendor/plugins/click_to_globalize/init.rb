# Force Globalize loading.
if Rails::VERSION::STRING.match /^1\.2+/
  load_plugin(File.join(RAILS_ROOT, 'vendor', 'plugins', 'globalize'))
else
  # Specify the plugins loading order: Click To Globalize should be the last one.
  plugins = (Dir["#{config.plugin_paths}/*"] - [ File.dirname(__FILE__) ]).map { |plugin| plugin.split(File::SEPARATOR).last}
  Rails::Initializer.run { |config| config.plugins = plugins }
end

require 'click_to_globalize'