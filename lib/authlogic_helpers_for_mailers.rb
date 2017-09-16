module AuthlogicHelpersForMailers
  
  ######## Authlogic helper methods

  %w(current_user_session current_user).each do |method_name|
    define_method(method_name) do
      nil
    end
  end
  
  %w(logged_in? logged_in_as_admin?).each do |method_name|
    define_method(method_name) do
      false
    end
  end

end
