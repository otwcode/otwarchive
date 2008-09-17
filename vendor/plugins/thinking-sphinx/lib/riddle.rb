require 'socket'
require 'timeout'
require 'riddle/client'
require 'riddle/client/filter'
require 'riddle/client/message'
require 'riddle/client/response'

module Riddle #:nodoc:
  class ConnectionError < StandardError #:nodoc:
  end
  
  module Version #:nodoc:
    Major   = 0
    Minor   = 9
    Tiny    = 8
    # Revision number for RubyForge's sake, taken from what Sphinx
    # outputs to the command line.
    Rev     = 1371
    # Release number to mark my own fixes, beyond feature parity with
    # Sphinx itself.
    Release = 0
    
    String      = [Major, Minor, Tiny].join('.')
    GemVersion  = [Major, Minor, Tiny, Rev, Release].join('.')
  end
end