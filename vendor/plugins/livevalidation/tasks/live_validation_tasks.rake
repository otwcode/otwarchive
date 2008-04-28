namespace :livevalidation do

  PLUGIN_ROOT = File.dirname(__FILE__) + '/../'

  desc 'Installs required javascript and stylesheet files to the public/ directory.'
  task :install do
    FileUtils.cp Dir[PLUGIN_ROOT + '/assets/javascripts/*.js'], RAILS_ROOT + '/public/javascripts'
    FileUtils.cp Dir[PLUGIN_ROOT + '/assets/stylesheets/*.css'], RAILS_ROOT + '/public/stylesheets'
  end

  desc 'Removes the javascript and stylesheet for the plugin.'
  task :remove do
    FileUtils.rm %{live_validation.js}.collect { |f| RAILS_ROOT + "/public/javascripts/" + f  }
    FileUtils.rm %{live_validation.css}.collect { |f| RAILS_ROOT + "/public/stylesheets/" + f  }
  end

end