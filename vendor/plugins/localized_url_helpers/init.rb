require "localized_url_helpers/route_set_methods"

RouteSet = ::ActionController::Routing::RouteSet
RouteSet.send(:include, LocalizedUrlHelpers::RouteSetMethods)
RouteSet::NamedRouteCollection.send(:include, LocalizedUrlHelpers::NamedRouteCollectionMethods)
