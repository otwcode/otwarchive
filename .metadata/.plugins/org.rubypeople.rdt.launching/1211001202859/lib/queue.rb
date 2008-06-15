=begin
----------------------------------------------------------- Class: Queue
     This class provides a way to synchronize communication between
     threads.

     Example:

       require 'thread'
     
       queue = Queue.new
     
       producer = Thread.new do
         5.times do |i|
           sleep rand(i) # simulate expense
           queue << i
           puts "#{i} produced"
         end
       end
     
       consumer = Thread.new do
         5.times do |i|
           value = queue.pop
           sleep rand(i/2) # simulate expense
           puts "consumed #{value}"
         end
       end
     
       consumer.join

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     <<, clear, deq, empty?, enq, length, num_waiting, pop, push, shift,
     size

=end
class Queue < Object

  # ------------------------------------------------------------ Queue#clear
  #      clear()
  # ------------------------------------------------------------------------
  #      Removes all objects from the queue.
  # 
  def clear
  end

  # -------------------------------------------------------------- Queue#pop
  #      pop(non_block=false)
  # ------------------------------------------------------------------------
  #      Retrieves data from the queue. If the queue is empty, the calling
  #      thread is suspended until data is pushed onto the queue. If
  #      +non_block+ is true, the thread isn't suspended, and an exception
  #      is raised.
  # 
  # 
  #      (also known as shift, deq)
  def pop(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ Queue#num_waiting
  #      num_waiting()
  # ------------------------------------------------------------------------
  #      Returns the number of threads waiting on the queue.
  # 
  def num_waiting
  end

  # ------------------------------------------------------------- Queue#size
  #      size()
  # ------------------------------------------------------------------------
  #      Alias for #length
  # 
  def size
  end

  def marshal_load(arg0)
  end

  # ------------------------------------------------------------- Queue#push
  #      push(obj)
  # ------------------------------------------------------------------------
  #      Pushes +obj+ to the queue.
  # 
  # 
  #      (also known as <<, enq)
  def push(arg0)
  end

  # --------------------------------------------------------------- Queue#<<
  #      <<(obj)
  # ------------------------------------------------------------------------
  #      Alias for #push
  # 
  def <<(arg0)
  end

  # ----------------------------------------------------------- Queue#empty?
  #      empty?()
  # ------------------------------------------------------------------------
  #      Returns +true+ is the queue is empty.
  # 
  def empty?
  end

  # ----------------------------------------------------------- Queue#length
  #      length()
  # ------------------------------------------------------------------------
  #      Returns the length of the queue.
  # 
  # 
  #      (also known as size)
  def length
  end

  def marshal_dump
  end

  # -------------------------------------------------------------- Queue#deq
  #      deq(non_block=false)
  # ------------------------------------------------------------------------
  #      Alias for #pop
  # 
  def deq(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Queue#shift
  #      shift(non_block=false)
  # ------------------------------------------------------------------------
  #      Alias for #pop
  # 
  def shift(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Queue#enq
  #      enq(obj)
  # ------------------------------------------------------------------------
  #      Alias for #push
  # 
  def enq(arg0)
  end

end
