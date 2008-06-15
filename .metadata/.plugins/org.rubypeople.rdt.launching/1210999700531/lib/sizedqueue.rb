=begin
---------------------------------------------- Class: SizedQueue < Queue
     This class represents queues of specified size capacity. The push
     operation may be blocked if the capacity is full.

     See Queue for an example of how a SizedQueue works.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     <<, deq, enq, max, max=, num_waiting, pop, push, shift

=end
class SizedQueue < Queue

  # --------------------------------------------------------- SizedQueue#pop
  #      pop(*args)
  # ------------------------------------------------------------------------
  #      Retrieves data from the queue and runs a waiting thread, if any.
  # 
  # 
  #      (also known as shift, deq)
  def pop
  end

  # ------------------------------------------------- SizedQueue#num_waiting
  #      num_waiting()
  # ------------------------------------------------------------------------
  #      Returns the number of threads waiting on the queue.
  # 
  def num_waiting
  end

  # --------------------------------------------------------- SizedQueue#max
  #      max()
  # ------------------------------------------------------------------------
  #      Returns the maximum size of the queue.
  # 
  def max
  end

  # -------------------------------------------------------- SizedQueue#push
  #      push(obj)
  # ------------------------------------------------------------------------
  #      Pushes +obj+ to the queue. If there is no space left in the queue,
  #      waits until space becomes available.
  # 
  # 
  #      (also known as <<, enq)
  def push
  end

  # ---------------------------------------------------------- SizedQueue#<<
  #      <<(obj)
  # ------------------------------------------------------------------------
  #      Alias for #push
  # 
  def <<
  end

  # -------------------------------------------------------- SizedQueue#max=
  #      max=(max)
  # ------------------------------------------------------------------------
  #      Sets the maximum size of the queue.
  # 
  def max=
  end

  # --------------------------------------------------------- SizedQueue#deq
  #      deq(*args)
  # ------------------------------------------------------------------------
  #      Alias for #pop
  # 
  def deq
  end

  # ------------------------------------------------------- SizedQueue#shift
  #      shift(*args)
  # ------------------------------------------------------------------------
  #      Alias for #pop
  # 
  def shift
  end

  # --------------------------------------------------------- SizedQueue#enq
  #      enq(obj)
  # ------------------------------------------------------------------------
  #      Alias for #push
  # 
  def enq
  end

end
