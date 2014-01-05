require 'plugins/livevalidation/live_validations'
require 'plugins/livevalidation/form_helpers'

# By default, don't do live validations -- 
# we'll specify only those fields we want live-validated in the views with :live => true
ActionView::live_validations = false
