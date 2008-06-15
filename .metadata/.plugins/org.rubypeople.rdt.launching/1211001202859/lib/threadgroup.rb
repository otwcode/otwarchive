=begin
----------------------------------------------------- Class: ThreadGroup
     +ThreadGroup+ provides a means of keeping track of a number of
     threads as a group. A +Thread+ can belong to only one +ThreadGroup+
     at a time; adding a thread to a new group will remove it from any
     previous group.

     Newly created threads belong to the same group as the thread from
     which they were created.

------------------------------------------------------------------------


Constants:
----------
     Default: thgroup_default


Instance methods:
-----------------
     add, enclose, enclosed?, list

=end
class ThreadGroup < Object

  # -------------------------------------------------- ThreadGroup#enclosed?
  #      thgrp.enclosed?   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _thgrp_ is enclosed. See also
  #      ThreadGroup#enclose.
  # 
  def enclosed?
  end

  # -------------------------------------------------------- ThreadGroup#add
  #      thgrp.add(thread)   => thgrp
  # ------------------------------------------------------------------------
  #      Adds the given _thread_ to this group, removing it from any other
  #      group to which it may have previously belonged.
  # 
  #         puts "Initial group is #{ThreadGroup::Default.list}"
  #         tg = ThreadGroup.new
  #         t1 = Thread.new { sleep }
  #         t2 = Thread.new { sleep }
  #         puts "t1 is #{t1}"
  #         puts "t2 is #{t2}"
  #         tg.add(t1)
  #         puts "Initial group now #{ThreadGroup::Default.list}"
  #         puts "tg group now #{tg.list}"
  # 
  #      _produces:_
  # 
  #         Initial group is #<Thread:0x401bdf4c>
  #         t1 is #<Thread:0x401b3c90>
  #         t2 is #<Thread:0x401b3c18>
  #         Initial group now #<Thread:0x401b3c18>#<Thread:0x401bdf4c>
  #         tg group now #<Thread:0x401b3c90>
  # 
  def add(arg0)
  end

  # ------------------------------------------------------- ThreadGroup#list
  #      thgrp.list   => array
  # ------------------------------------------------------------------------
  #      Returns an array of all existing +Thread+ objects that belong to
  #      this group.
  # 
  #         ThreadGroup::Default.list   #=> [#<Thread:0x401bdf4c run>]
  # 
  def list
  end

  # ---------------------------------------------------- ThreadGroup#enclose
  #      thgrp.enclose   => thgrp
  # ------------------------------------------------------------------------
  #      Prevents threads from being added to or removed from the receiving
  #      +ThreadGroup+. New threads can still be started in an enclosed
  #      +ThreadGroup+.
  # 
  #         ThreadGroup::Default.enclose        #=> #<ThreadGroup:0x4029d914>
  #         thr = Thread::new { Thread.stop }   #=> #<Thread:0x402a7210 sleep>
  #         tg = ThreadGroup::new               #=> #<ThreadGroup:0x402752d4>
  #         tg.add thr
  # 
  #      _produces:_
  # 
  #         ThreadError: can't move from the enclosed thread group
  # 
  def enclose
  end

end
