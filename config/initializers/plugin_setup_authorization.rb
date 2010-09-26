# Authorization plugin for role based access control
# You can override default authorization system constants here.

# Can be 'object roles' or 'hardwired'
AUTHORIZATION_MIXIN = "object roles"

# NOTE : If you use modular controllers like '/admin/products' be sure
# to redirect to something like '/sessions' controller (with a leading slash)
# as shown in the example below or you will not get redirected properly
#
# This can be set to a hash or to an explicit path like '/login'
#
#LOGIN_REQUIRED_REDIRECTION = { :controller => '/session', :action => 'new' }
#PERMISSION_DENIED_REDIRECTION = { :controller => :works, :action => 'index' }

# The method your auth scheme uses to store the location to redirect back to
STORE_LOCATION_METHOD = :store_location

