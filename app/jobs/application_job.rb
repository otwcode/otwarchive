class ApplicationJob < ActiveJob::Base
  queue_as :utilities
end
