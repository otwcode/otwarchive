# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# when testing caching, uncomment, and don't forget you will
# have to restart your server after every code change!
# config.cache_classes                                 = true
# config.action_controller.perform_caching             = true
# config.cache_store = :mem_cache_store
# config.cache_store = :memory_store
# Note: if you don't have memcached installed locally, you can use :memory_store
# for testing, but don't write code that relies on regexp cache keys, because 
# that code will break when you get to production!

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

