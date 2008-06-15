=begin
----------------------------------------------- Class: ConditionVariable
     ConditionVariable objects augment class Mutex. Using condition
     variables, it is possible to suspend while in the middle of a
     critical section until a resource becomes available.

     Example:

       require 'thread'
     
       mutex = Mutex.new
       resource = ConditionVariable.new
     
       a = Thread.new {
         mutex.synchronize {
           # Thread 'a' now needs the resource
           resource.wait(mutex)
           # 'a' can now have the resource
         }
       }
     
       b = Thread.new {
         mutex.synchronize {
           # Thread 'b' has finished using the resource
           resource.signal
         }
       }

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     broadcast, signal, wait

=end
class ConditionVariable < Object

  # -------------------------------------------- ConditionVariable#broadcast
  #      broadcast()
  # ------------------------------------------------------------------------
  #      Wakes up all threads waiting for this lock.
  # 
  def broadcast
  end

  def marshal_load(arg0)
  end

  def marshal_dump
  end

  # ------------------------------------------------- ConditionVariable#wait
  #      wait(mutex)
  # ------------------------------------------------------------------------
  #      Releases the lock held in +mutex+ and waits; reacquires the lock on
  #      wakeup.
  # 
  def wait(arg0)
  end

  # ----------------------------------------------- ConditionVariable#signal
  #      signal()
  # ------------------------------------------------------------------------
  #      Wakes up the first thread in line waiting for this lock.
  # 
  def signal
  end

end
