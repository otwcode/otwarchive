module ActionView
  module Helpers
    module ActiveRecordHelper
      # Returns a string with a div containing all the error messages for the object located as an instance variable by the name
      # of <tt>object_name</tt>. This div can be tailored by the following options:
      #
      # * <tt>header_tag</tt> - Used for the header of the error div (default: h2)
      # * <tt>id</tt> - The id of the error div (default: errorExplanation)
      # * <tt>class</tt> - The class of the error div (default: errorExplanation)
      #
      # NOTE: This is a pre-packaged presentation of the errors with embedded strings and a certain HTML structure. If what
      # you need is significantly different from the default presentation, it makes plenty of sense to access the object.errors
      # instance yourself and set it up. View the source of this method to see how easy it is.
      #
      # Retrofitted for Globalize by André Camargo
      def error_messages_for(object_name, options = {})
        options = options.symbolize_keys
        object = instance_variable_get("@#{object_name}")
        unless object.errors.empty?
          content_tag("div",
            content_tag(
              options[:header_tag] || "h2",
              "%d errors prohibited this #{object_name.to_s.gsub("_", " ").t} from being saved" / object.errors.count
            ) +
            content_tag("p", "There were problems with the following fields:".t) +
            content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
            "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
          )
        end
      end
    end
  end
end
