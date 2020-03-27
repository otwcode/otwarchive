# There is a possible XSS vulnerability in ActionView's JavaScript
# literal escape helpers. Views that use the j or escape_javascript methods
# may be susceptible to XSS attacks.

# Monkey patch from https://github.com/advisories/GHSA-65cv-r6x7-79hv.
# TODO: AO3-5765 Remove monkey patch once we're on Rails 5.2.
ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP.merge!(
  {
    "`" => "\\`",
    "$" => "\\$"
  }
)

module ActionView::Helpers::JavaScriptHelper
  alias :old_ej :escape_javascript
  alias :old_j :j

  def escape_javascript(javascript)
    javascript = javascript.to_s
    if javascript.empty?
      result = ""
    else
      result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
    end
    javascript.html_safe? ? result.html_safe : result
  end

  alias :j :escape_javascript
end
