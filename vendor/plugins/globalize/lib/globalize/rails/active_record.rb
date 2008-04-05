module ActiveRecord # :nodoc:

  # Overrode Errors methods to handle numbers correctly for translation, and
  # to automatically translate error messages. Messages are translated after
  # the field names have been substituted.
  class Errors

    # Like the regular #add, but automatically translates the error message.
    # Takes an extra +num+ argument to support pluralization.
    def add(attribute, msg = @@default_error_messages[:invalid], num = nil)
      @errors[attribute.to_s] = [] if @errors[attribute.to_s].nil?
      @errors[attribute.to_s] << [ msg, num ]
    end

    # Like the regular add_to_base, but automatically translates the error message.
    # Takes an extra +num+ argument to support pluralization.
    def add_to_base(msg, num = nil)
      add(:base, msg, num)
    end

    # Like the regular add_on_boundary_breaking, but automatically translates the error message.
    def add_on_boundary_breaking(attributes, range,
        too_long_msg = @@default_error_messages[:too_long],
        too_short_msg = @@default_error_messages[:too_short])
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        add(attr, too_short_msg, range.begin) if value && value.length < range.begin
        add(attr, too_long_msg, range.end) if value && value.length > range.end
      end
    end

    def full_messages # :nodoc:
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?
          msg = [ msg ].flatten
          msg_text, msg_num = msg
          if attr == "base"
            full_messages << msg_text / msg_num
          else
            full_messages <<
              (@base.class.human_attribute_name(attr) + " " + msg_text) / msg_num
          end
        end
      end

      return full_messages
    end

    # * Returns nil, if no errors are associated with the specified +attribute+.
    # * Returns the error message, if one error is associated with the specified +attribute+.
    # * Returns an array of error messages, if more than one error is associated with the specified +attribute+.
    def on(attribute)
      if @errors[attribute.to_s].nil?
        return nil
      else
        msgs = @errors[attribute.to_s]
        txt_msgs = msgs.map {|msg| msg.kind_of?(Array) ? msg.first / msg.last : msg.first.t }
        return txt_msgs.length == 1 ? txt_msgs.first : txt_msgs
      end
    end

  end

  module Validations # :nodoc: all
    module ClassMethods
      def validates_length_of(*attrs)
        # Merge given options with defaults.
        options = {
          :too_long     => ActiveRecord::Errors.default_error_messages[:too_long],
          :too_short    => ActiveRecord::Errors.default_error_messages[:too_short],
          :wrong_length => ActiveRecord::Errors.default_error_messages[:wrong_length]
        }.merge(DEFAULT_VALIDATION_OPTIONS)
        options.update(attrs.pop.symbolize_keys) if attrs.last.is_a?(Hash)

        # Ensure that one and only one range option is specified.
        range_options = ALL_RANGE_OPTIONS & options.keys
        case range_options.size
          when 0
            raise ArgumentError, 'Range unspecified.  Specify the :within, :maximum, :minimum, or :is option.'
          when 1
            # Valid number of options; do nothing.
          else
            raise ArgumentError, 'Too many range options specified.  Choose only one.'
        end

        # Get range option and value.
        option = range_options.first
        option_value = options[range_options.first]

        case option
        when :within, :in
          raise ArgumentError, ":#{option} must be a Range" unless option_value.is_a?(Range)

          too_short = options[:too_short]
          too_long  = options[:too_long]

          validates_each(attrs, options) do |record, attr, value|
            if value.nil? or value.size < option_value.begin
              record.errors.add(attr, too_short, option_value.begin)
            elsif value.size > option_value.end
              record.errors.add(attr, too_long, option_value.end)
            end
          end
        when :is, :minimum, :maximum
          raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0

          # Declare different validations per option.
          validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
          message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

          message = options[:message] || options[message_options[option]]

          validates_each(attrs, options) do |record, attr, value|
            record.errors.add(attr, message, option_value) unless !value.nil? and value.size.method(validity_checks[option])[option_value]
          end
        end
      end
    end
  end
end

class ActiveRecord::Base # :nodoc:
  include Globalize::DbTranslate
end


