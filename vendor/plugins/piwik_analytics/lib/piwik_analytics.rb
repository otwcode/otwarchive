# PiwikAnalytics
require 'active_support'

module PiwikAnalytics
  module PiwikAnalyticsMixin
    def piwik_tracking_js
      if Config.use_async
        <<-code
        <!-- Piwik -->
        <script type="text/javascript">
        var _paq = _paq || [];
        (function(){
            var u=(("https:" == document.location.protocol) ? "https://#{Config.url}" : "http://#{Config.url}");
            _paq.push(['setSiteId', #{Config.id_site}]);
            _paq.push(['setTrackerUrl', u+'piwik.php']);
            _paq.push(['trackPageView']);
            var d=document,
                g=d.createElement('script'),
                s=d.getElementsByTagName('script')[0];
                g.type='text/javascript';
                g.defer=true;
                g.async=true;
                g.src=u+'piwik.js';
                s.parentNode.insertBefore(g,s);
        })();
        </script>
        <!-- End Piwik Tag -->
        code
      else
        <<-code
        <!-- Piwik -->
        <script type="text/javascript">
        var pkBaseURL = (("https:" == document.location.protocol) ? "https://#{Config.url}" : "http://#{Config.url}");
        document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
        </script><script type="text/javascript">
        try {
                var piwikTracker = Piwik.getTracker(pkBaseURL + "piwik.php", #{Config.id_site});
                piwikTracker.trackPageView();
                piwikTracker.enableLinkTracking();
        } catch( err ) {}
        </script>
        <!-- End Piwik Tag -->
        code
      end
    end

    def add_piwik_analytics_tracking
      if Config.enabled? request.format
        if Config.use_async
          self.response.body= response.body.sub /<\/[hH][eE][aA][dD]>/, "#{piwik_tracking_js}</head>" if response.body.respond_to?(:sub!)
        else
          self.response.body= response.body.sub! /<\/[bB][oO][dD][yY]>/, "#{piwik_tracking_js}</body>" if response.body.respond_to?(:sub!)
        end
      end
    end
  end

  class PiwikAnalyticsConfigurationError < StandardError; end

  class Config
    @@id_site = nil
    cattr_accessor :id_site

    @@url = nil
    cattr_accessor :url

    @@use_async = false
    cattr_accessor :use_async

    @@environments = ["production"]
    cattr_accessor :environments

    @@formats = [:html, :all]
    cattr_accessor :formats

    def self.enabled?(format)
      raise PiwikAnalytics::PiwikAnalsyticsConfigurationError if id_site.blank? || url.blank?
      environments.include?(Rails.env) && formats.include?(format.to_sym)
    end
  end
end
