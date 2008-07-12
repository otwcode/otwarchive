require 'socket'
require 'riddle/client'
require 'riddle/client/filter'
require 'riddle/client/message'
require 'riddle/client/response'

module Riddle #:nodoc:
  class ConnectionError < StandardError #:nodoc:
  end
  
  module Version #:nodoc:
    Major = 0
    Minor = 9
    Tiny  = 8
    Rev   = 1065
    
    String = [Major, Minor, Tiny].join('.') + "r#{Rev}"
  end
end