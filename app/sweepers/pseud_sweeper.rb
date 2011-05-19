class PseudSweeper < ActionController::Caching::Sweeper
  observe User, Pseud
  
  def after_create(record)
    record.add_to_autocomplete if record.is_a?(Pseud)
  end
  
  def before_update(record)
    if record.changed.include?(:name)
      if record.is_a?(User)
        record.pseuds.each {|pseud| pseud.remove_from_autocomplete}
      else
        record.remove_from_autocomplete
      end
    end
  end
  
  def after_update(record)
    if record.changed.include?(:name)
      if record.is_a?(User)
        record.pseuds.each {|pseud| pseud.add_to_autocomplete}
      else
        record.add_to_autocomplete
      end
    end
  end

  def before_destroy(record)
    record.remove_from_autocomplete if record.is_a?(Pseud)
  end
  
end