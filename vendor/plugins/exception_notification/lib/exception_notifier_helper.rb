require 'pp'

# Copyright (c) 2005 Jamis Buck
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module ExceptionNotifierHelper
  VIEW_PATH = "views/exception_notifier"
  APP_PATH = "#{RAILS_ROOT}/app/#{VIEW_PATH}"
  PARAM_FILTER_REPLACEMENT = "[FILTERED]"

  def render_section(section)
    RAILS_DEFAULT_LOGGER.info("rendering section #{section.inspect}")
    summary = render_overridable(section).strip
    unless summary.blank?
      title = render_overridable(:title, :locals => { :title => section }).strip
      "#{title}\n\n#{summary.gsub(/^/, "  ")}\n\n"
    end
  end

  def render_overridable(partial, options={})
    if File.exist?(path = "#{APP_PATH}/_#{partial}.rhtml")
      render(options.merge(:file => path, :use_full_path => false))
    elsif File.exist?(path = "#{File.dirname(__FILE__)}/../#{VIEW_PATH}/_#{partial}.rhtml")
      render(options.merge(:file => path, :use_full_path => false))
    else
      ""
    end
  end

  def inspect_model_object(model, locals={})
    render_overridable(:inspect_model,
      :locals => { :inspect_model => model,
                   :show_instance_variables => true,
                   :show_attributes => true }.merge(locals))
  end

  def inspect_value(value)
    len = 512
    result = object_to_yaml(value).gsub(/\n/, "\n  ").strip
    result = result[0,len] + "... (#{result.length-len} bytes more)" if result.length > len+20
    result
  end

  def object_to_yaml(object)
    object.to_yaml.sub(/^---\s*/m, "")
  end

  def exclude_raw_post_parameters?
    @controller && @controller.respond_to?(:filter_parameters)
  end
  
  def filter_sensitive_post_data_parameters(parameters)
    exclude_raw_post_parameters? ? @controller.__send__(:filter_parameters, parameters) : parameters
  end
  
  def filter_sensitive_post_data_from_env(env_key, env_value)
    return env_value unless exclude_raw_post_parameters?
    return PARAM_FILTER_REPLACEMENT if (env_key =~ /RAW_POST_DATA/i)
    return @controller.__send__(:filter_parameters, {env_key => env_value}).values[0]
  end
end
