require 'piwik_analytics'
ActionController::Base.send :include, PiwikAnalytics::PiwikAnalyticsMixin
ActionController::Base.send :after_filter, :add_piwik_analytics_tracking
