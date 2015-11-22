class PseudSweeper < ActionController::Caching::Sweeper
  observe User, Pseud
  
  def after_create(record)
    record.add_to_autocomplete if record.is_a?(Pseud)
  end
  
  def before_update(record)
    if record.changed.include?("name") || record.changed.include?("login")
      if record.is_a?(User)
        record.pseuds.each(&:remove_stale_from_autocomplete)
      else
        record.remove_stale_from_autocomplete
      end
    end
  end
  
  def after_update(record)
    if record.changed.include?("name") || record.changed.include?("login")
      if record.is_a?(User)
        record.pseuds.each do |pseud|
          # have to reload the pseud from the db otherwise it has the outdated login
          pseud.reload
          pseud.add_to_autocomplete
        end
      else
        record.add_to_autocomplete
      end
    end
  end

  def before_destroy(record)
    record.remove_from_autocomplete if record.is_a?(Pseud)
  end
  
end