# Enable handling exceptions with dynamic error pages in production
# See http://accuser.cc/posts/1-rails-3-0-exception-handling
require 'action_dispatch/middleware/show_exceptions'

module ActionDispatch
  class ShowExceptions
    
    private
      def render_exception(env, exception)
        log_error(exception)

        request = Request.new(env)
        if @consider_all_requests_local || request.local?
          rescue_action_locally(request, exception)
        else          
          status = status_code(exception)
          Airbrake.notify(exception) if Rails.env == 'production'
          begin
            body = ErrorsController.action(rescue_responses[exception.class.name]).call(env)
            body
          rescue
            rescue_action_in_public(exception)
          end            
        end
      rescue Exception => failsafe_error
        $stderr.puts "Error during failsafe response: #{failsafe_error}\n #{failsafe_error.backtrace * "\n "}"
        FAILSAFE_RESPONSE
      end

  end
end

