module Authorization #:nodoc:

  # Base error class for Authorization module
  class AuthorizationError < StandardError
  end

  # Raised when the authorization expression is invalid (cannot be parsed)
  class AuthorizationExpressionInvalid < AuthorizationError
  end

  # Raised when we can't find the current user
  class CannotObtainUserObject < AuthorizationError
  end

  # Raised when an authorization expression contains a model class that doesn't exist
  class CannotObtainModelClass < AuthorizationError
  end

  # Raised when an authorization expression contains a model reference that doesn't exist
  class CannotObtainModelObject < AuthorizationError
  end

  # Raised when the obtained user object doesn't implement #id
  class UserDoesntImplementID < AuthorizationError
  end

  # Raised when the obtained user object doesn't implement #has_role?
  class UserDoesntImplementRoles < AuthorizationError
  end

  # Raised when the obtained model doesn't implement #accepts_role?
  class ModelDoesntImplementRoles < AuthorizationError
  end

  class CannotSetRoleWhenHardwired < AuthorizationError
  end

  class CannotSetObjectRoleWhenSimpleRoleTable < AuthorizationError
  end

end