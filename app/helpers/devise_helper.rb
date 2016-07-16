# Helper for Devise views
module DeviseHelper
  def devise_error_messages!
    return '' unless devise_error_messages?

    messages = resource.errors.full_messages
                       .map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
    <div class="error">
       <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    !resource.errors.empty?
  end
end
