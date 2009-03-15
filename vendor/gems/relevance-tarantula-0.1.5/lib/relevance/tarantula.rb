TARANTULA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../.."))

require 'forwardable'
require 'erb'
require 'rubygems'
require 'active_support'
require 'action_controller'

# bringing in xss-shield requires a bunch of other dependencies
# still not certain about this, if it ruins your world please let me know
#xss_shield_path = File.join(TARANTULA_ROOT, %w{vendor xss-shield})
#$: << File.join(xss_shield_path, "lib")
#require File.join(xss_shield_path, "init")

require 'htmlentities'

module Relevance; end
module Relevance; module CoreExtensions; end; end
module Relevance
  module Tarantula
    def tarantula_home
      File.expand_path(File.join(File.dirname(__FILE__), "../.."))
    end
    def log(msg)
      puts msg if verbose
    end
    def rails_root
      ::RAILS_ROOT
    end
    def verbose
      ENV["VERBOSE"]
    end
  end
end

require File.expand_path(File.join(File.dirname(__FILE__), "core_extensions", "test_case"))
require File.expand_path(File.join(File.dirname(__FILE__), "core_extensions", "ellipsize"))
require File.expand_path(File.join(File.dirname(__FILE__), "core_extensions", "file"))
require File.expand_path(File.join(File.dirname(__FILE__), "core_extensions", "response"))
require File.expand_path(File.join(File.dirname(__FILE__), "core_extensions", "metaclass"))

require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "html_reporter"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "html_report_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "io_reporter"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "recording"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "response"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "result"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "log_grabber"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "invalid_html_handler"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "transform"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "crawler"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "form"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "form_submission"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "attack"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "attack_form_submission"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "attack_handler"))
require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "link"))

require File.expand_path(File.join(File.dirname(__FILE__), "tarantula", "tidy_handler")) if ENV['TIDY_PATH']
