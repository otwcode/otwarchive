module ActiveRecord
  class Errors
    # Remove a single error from the collection by key. 
    def delete(key) 
      @errors.delete(key.to_s) 
    end 
  end 
end 
