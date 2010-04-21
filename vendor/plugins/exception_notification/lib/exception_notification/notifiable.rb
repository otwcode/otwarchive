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
module ExceptionNotification::Notifiable
  def self.included(target)
    target.extend(ClassMethods)
    target.skip_exception_notifications false
  end

  module ClassMethods
    def exception_data(deliverer=self)
      if deliverer == self
        read_inheritable_attribute(:exception_data)
      else
        write_inheritable_attribute(:exception_data, deliverer)
      end
    end
    
    def skip_exception_notifications(boolean=true)
      write_inheritable_attribute(:skip_exception_notifications, boolean)
    end
    
    def skip_exception_notifications?
      read_inheritable_attribute(:skip_exception_notifications)
    end
  end

private

  def rescue_action_in_public(exception)
    super
    notify_about_exception(exception) if deliver_exception_notification?
  end
  
  def deliver_exception_notification?
    !self.class.skip_exception_notifications? && ![404, "404 Not Found"].include?(response.status)
  end
  
  def notify_about_exception(exception)
    deliverer = self.class.exception_data
    data = case deliverer
      when nil then {}
      when Symbol then send(deliverer)
      when Proc then deliverer.call(self)
    end

    ExceptionNotification::Notifier.deliver_exception_notification(exception, self, request, data)
  end
end