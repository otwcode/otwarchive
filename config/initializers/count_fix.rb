# From http://gist.github.com/107168
# drop this in config/initializers/count_fix.rb to work around
# hmt/named_scope count bug https://rails.lighthouseapp.com/projects/8994/tickets/2189
 
class ActiveRecord::Base
  protected
    def self.construct_count_options_from_args(*args)
      name_and_options = super
      name_and_options[0] = '*' if name_and_options[0].is_a?(String) && name_and_options[0] =~ /\.\*$/
      name_and_options
    end
end