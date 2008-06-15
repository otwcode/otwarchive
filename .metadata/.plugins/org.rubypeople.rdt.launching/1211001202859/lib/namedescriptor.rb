=begin
-------------------------------------------------- Class: NameDescriptor
     Break argument into its constituent class or module names, an
     optional method type, and a method name

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     full_class_name

Attributes:
     class_names, is_class_method, method_name

=end
class NameDescriptor < Object

  def method_name
  end

  def class_names
  end

  # ----------------------------------------- NameDescriptor#full_class_name
  #      full_class_name()
  # ------------------------------------------------------------------------
  #      Return the full class name (with '::' between the components) or ""
  #      if there's no class name
  # 
  def full_class_name
  end

  def is_class_method
  end

end
