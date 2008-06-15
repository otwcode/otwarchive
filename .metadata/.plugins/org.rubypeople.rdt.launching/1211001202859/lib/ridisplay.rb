=begin
------------------------------------------------------- Class: RiDisplay
     This is a kind of 'flag' module. If you want to write your own 'ri'
     display module (perhaps because you'r writing an IDE or somesuch
     beast), you simply write a class which implements the various
     'display' methods in 'DefaultDisplay', and include the 'RiDisplay'
     module in that class.

     To access your class from the command line, you can do

        ruby -r <your source file>  ../ri ....

     If folks _really_ want to do this from the command line, I'll build
     an option in

------------------------------------------------------------------------


Class methods:
--------------
     append_features, new

=end
module RiDisplay

  # --------------------------------------------- RiDisplay::append_features
  #      RiDisplay::append_features(display_class)
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.append_features(arg0)
  end

  # --------------------------------------------------------- RiDisplay::new
  #      RiDisplay::new(*args)
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.new(arg0, arg1, *rest)
  end

end
