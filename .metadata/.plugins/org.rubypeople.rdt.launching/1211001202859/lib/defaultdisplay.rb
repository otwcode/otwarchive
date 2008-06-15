=begin
-------------------------------------------------- Class: DefaultDisplay
     A paging display module. Uses the ri_formatter class to do the
     actual presentation

------------------------------------------------------------------------


Includes:
---------
     RiDisplay()


Class methods:
--------------
     new


Instance methods:
-----------------
     display_class_info, display_class_list, display_flow,
     display_method_info, display_method_list, display_params,
     display_usage, list_known_classes, list_known_names, page,
     setup_pager, warn_no_database

=end
class DefaultDisplay < Object

  # ------------------------------------- DefaultDisplay#display_method_info
  #      display_method_info(method)
  # ------------------------------------------------------------------------
  #      (no description...)
  def display_method_info
  end

  # ------------------------------------------- DefaultDisplay#display_usage
  #      display_usage()
  # ------------------------------------------------------------------------
  #      (no description...)
  def display_usage
  end

  # -------------------------------------- DefaultDisplay#display_class_info
  #      display_class_info(klass, ri_reader)
  # ------------------------------------------------------------------------
  #      (no description...)
  def display_class_info
  end

  # ------------------------------------- DefaultDisplay#display_method_list
  #      display_method_list(methods)
  # ------------------------------------------------------------------------
  #      Display a list of method names
  # 
  def display_method_list
  end

  # -------------------------------------- DefaultDisplay#list_known_classes
  #      list_known_classes(classes)
  # ------------------------------------------------------------------------
  #      (no description...)
  def list_known_classes
  end

  # ---------------------------------------- DefaultDisplay#list_known_names
  #      list_known_names(names)
  # ------------------------------------------------------------------------
  #      (no description...)
  def list_known_names
  end

  # -------------------------------------- DefaultDisplay#display_class_list
  #      display_class_list(namespaces)
  # ------------------------------------------------------------------------
  #      (no description...)
  def display_class_list
  end

end
