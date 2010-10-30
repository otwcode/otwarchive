# This module, when included into ActiveSupport::BufferedLogger, improves the
# logging format. See the README file for more info.
#
# This is distributed under a Creative Commons "Attribution-Share Alike"
# license: for details see: 
# http://creativecommons.org/licenses/by-sa/3.0/
#
module PaulDowman
  module RailsPlugins
    module BetterLogging
      
      LENGTH = ActiveSupport::BufferedLogger::Severity.constants.map{|c| c.to_s.length}.max
      
      def self.included(base)
        base.class_eval do
          alias_method_chain :add, :extra_info
          alias_method_chain :error, :exception_param
          alias_method_chain :warn, :exception_param
        end
        
        # Get the length to format the output so that the pid column lines up.
        # The severity levels probably won't change but this avoids hard-coding
        # them anyway, just in case.
        # Most of this is done with class_eval so it should only be done once 
        # while the class is being loaded.
        if_stmts = ""
        for c in ActiveSupport::BufferedLogger::Severity.constants
          if_stmts += <<-EOT
            if severity == #{c}
              severity_name = sprintf("%1$*2$s", "#{c}", #{LENGTH * -1})
              use_colour = false
              if Rails.version.to_i >= 3
                use_colour = true if ActiveSupport::LogSubscriber.colorize_logging
              else
                use_colour = true if defined?(ActiveRecord) && ActiveRecord::Base.colorize_logging
              end
              if use_colour
                if severity == INFO
                  severity_name = "\033[32m" + severity_name + "\033[0m"
                elsif severity == WARN
                  severity_name = "\033[33m" + severity_name + "\033[0m"
                elsif severity == ERROR || severity == FATAL
                  severity_name = "\033[31m" + severity_name + "\033[0m"
                end
              end
              return severity_name
            end
          EOT
        end
        base.class_eval <<-EOT, __FILE__, __LINE__
          def self.severity_name(severity)
            #{if_stmts}
            return "UNKNOWN"
          end
        EOT
      end
      

      def self.verbose=(boolean)
        @@verbose = boolean
      end
      
      def self.custom=(string)
        @@custom = string
        @@line_prefix = format_line_prefix
      end
      
      def self.hostname_maxlen=(integer)
        @@hostname_maxlen = integer
        @@line_prefix = format_line_prefix
      end
      
      def self.format_line_prefix
        if @@full_hostname.length < @@hostname_maxlen
          hostname = @@full_hostname
        else
          hostname = @@full_hostname[-(@@hostname_maxlen)..-1]
        end
        
        line_prefix = sprintf("%1$*2$s", "#{hostname}.#{@@pid}  ", -(7 + hostname.length))
        line_prefix = "#{@@custom}  #{line_prefix}" if @@custom
        return line_prefix
      end
      
      def self.get_hostname
        `hostname -s`.strip
      end
      
      # The following are cached as class variables for speed.

      # These are configurable, put something like the following in an initializer:
      #   PaulDowman::RailsPlugins::BetterLogging.verbose = false
      @@verbose = Rails.env != "development"
      @@full_hostname = get_hostname
      @@hostname_maxlen = 10
      @@custom = nil
      
      # These are not configurable
      @@pid = $$
      @@line_prefix = format_line_prefix

            
      # the cached pid can be wrong after a fork(), this checks if it has changed and
      # re-caches the line_prefix
      def update_pid
        if @@pid != $$
          @@pid = $$
          @@line_prefix = BetterLogging.format_line_prefix
        end
      end
      
      def add_with_extra_info(severity, message = nil, progname = nil, &block)
        update_pid
        time = @@verbose ? "#{Time.new.strftime('%H:%M:%S')}  " : ""
        message = "#{time}#{ActiveSupport::BufferedLogger.severity_name(severity)}  #{message}"
        
        # Make sure every line has the PID and hostname and custom string 
        # so we can use grep to isolate output from one process or server.
        # gsub works even when the output contains "\n", though there's
        # probably a small performance cost.
        message = message.gsub(/^/, @@line_prefix) if @@verbose
        
        add_without_extra_info(severity, message, progname, &block)
      end
      
      
      # add an optional second parameter to the error & warn methods to allow a stack trace:
            
      def error_with_exception_param(message, exception = nil)
        message += "\n#{exception.inspect}\n#{exception.backtrace.join("\n")}" if exception
        error_without_exception_param(message)
      end
      
      def warn_with_exception_param(message, exception = nil)
        message += "\n#{exception.inspect}\n#{exception.backtrace.join("\n")}" if exception
        warn_without_exception_param(message)
      end
    end
  end
end
