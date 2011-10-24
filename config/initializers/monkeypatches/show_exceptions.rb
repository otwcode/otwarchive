# Enable handling exceptions with dynamic error pages in production
# See http://accuser.cc/posts/1-rails-3-0-exception-handling
require 'action_dispatch/middleware/show_exceptions'

module ActionDispatch
  class ShowExceptions
    private
      def render_exception_with_template(env, exception)
        body = ErrorsController.action(rescue_responses[exception.class.name]).call(env)
        log_error(exception)
        notify_airbrake(exception)
        body
      rescue
        render_exception_without_template(env, exception)
      end

      alias_method_chain :render_exception, :template if Rails.env == "production"
  end
end

