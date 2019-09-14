# allow users to specify class attributes in their html
# scrub invalid class names
module OTWSanitize
  class UserClassSanitizer
    def self.transformer
      lambda do |env|
        new(env[:node]).sanitized_node
      end
    end

    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Update the class attribute with the sanitized value
    def sanitized_node
      return if user_classes.blank?
      node['class'] = sanitized_classes
      node
    end

    # Turn the class string into an array, select the valid values
    # then rejoin them
    def sanitized_classes
      user_classes.split(" ").
                   select { |user_class| valid_class?(user_class) }.
                   join(" ")
    end

    # let through alphanumeric class names with a dash/underscore
    def valid_class?(str)
      str =~ /^[a-zA-Z][\w\-]+$/
    end

    # If the element is something like <p class="apple banana">
    # then the value will be the string "apple banana"
    def user_classes
      node['class']
    end
  end
end
