module Riddle
  class Client
    # This class takes care of the translation of ints, strings and arrays to
    # the format required by the Sphinx service.
    class Message
      def initialize
        @message = ""
        @size_method = @message.respond_to?(:bytesize) ? :bytesize : :length
      end
      
      # Append raw data (only use if you know what you're doing)
      def append(*args)
        return if args.length == 0
        
        args.each { |arg| @message << arg }
      end
      
      # Append a string's length, then the string itself
      def append_string(str)
        @message << [str.send(@size_method)].pack('N') + str
      end
      
      # Append an integer
      def append_int(int)
        @message << [int].pack('N')
      end
      
      def append_64bit_int(int)
        @message << [int >> 32, int & 0xFFFFFFFF].pack('NN')
      end
      
      # Append a float
      def append_float(float)
        @message << [float].pack('f').unpack('L*').pack("N")
      end
      
      # Append multiple integers
      def append_ints(*ints)
        ints.each { |int| append_int(int) }
      end
      
      def append_64bit_ints(*ints)
        ints.each { |int| append_64bit_int(int) }
      end
      
      # Append multiple floats
      def append_floats(*floats)
        floats.each { |float| append_float(float) }
      end
      
      # Append an array of strings - first appends the length of the array,
      # then each item's length and value.
      def append_array(array)
        append_int(array.length)
        
        array.each { |item| append_string(item) }
      end
      
      # Returns the entire message
      def to_s
        @message
      end
    end
  end
end