=begin
--------------------------------------------------------- Class: Timeout

DESCRIPTION
===========
     A way of performing a potentially long-running operation in a
     thread, and terminating it's execution if it hasn't finished within
     fixed amount of time.

     Previous versions of timeout didn't use a module for namespace.
     This version provides both Timeout.timeout, and a
     backwards-compatible #timeout.


SYNOPSIS
========
       require 'timeout'
       status = Timeout::timeout(5) {
         # Something that should be interrupted if it takes too much time...
       }

------------------------------------------------------------------------


Instance methods:
-----------------
     timeout

=end
module Timeout

  def self.timeout(arg0, arg1, arg2, *rest)
  end

end
