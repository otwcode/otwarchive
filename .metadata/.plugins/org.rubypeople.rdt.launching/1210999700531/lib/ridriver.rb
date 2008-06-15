=begin
-------------------------------------------------------- Class: RiDriver
     (no description...)
------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     get_info_for, process_args, report_class_stuff,
     report_method_stuff, report_missing_documentation

=end
class RiDriver < Object

  # ---------------------------------- RiDriver#report_missing_documentation
  #      report_missing_documentation(path)
  # ------------------------------------------------------------------------
  #      Couldn't find documentation in +path+, so tell the user what to do
  # 
  def report_missing_documentation(arg0)
  end

  # -------------------------------------------------- RiDriver#get_info_for
  #      get_info_for(arg)
  # ------------------------------------------------------------------------
  #      (no description...)
  def get_info_for(arg0)
  end

  def display
  end

  # ------------------------------------------- RiDriver#report_method_stuff
  #      report_method_stuff(requested_method_name, methods)
  # ------------------------------------------------------------------------
  #      If the list of matching methods contains exactly one entry, or if
  #      it contains an entry that exactly matches the requested method,
  #      then display that entry, otherwise display the list of matching
  #      method names
  # 
  def report_method_stuff(arg0, arg1)
  end

  # -------------------------------------------- RiDriver#report_class_stuff
  #      report_class_stuff(namespaces)
  # ------------------------------------------------------------------------
  #      (no description...)
  def report_class_stuff(arg0)
  end

  # -------------------------------------------------- RiDriver#process_args
  #      process_args()
  # ------------------------------------------------------------------------
  #      (no description...)
  def process_args
  end

end
