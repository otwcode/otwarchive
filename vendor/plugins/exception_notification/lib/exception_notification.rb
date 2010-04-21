require "action_mailer"
module ExceptionNotification
  autoload :Notifiable,     'exception_notification/notifiable'
  autoload :Notifier,       'exception_notification/notifier'
  #autoload :NotifierHelper, 'exception_notification/notifier_helper'
  autoload :ConsiderLocal,  'exception_notification/consider_local'
end