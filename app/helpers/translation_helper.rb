module TranslationHelper
  
  # Returns the status of a localized translation with a class for css styling
  def translation_status(main_translation, local_translation)
    if local_translation.betaed? || !local_translation.text.blank?
      if main_translation.updated_at > local_translation.updated_at
        "<span class='updated'>Main translation has been updated</span>"
      elsif local_translation.betaed
        "<span class='betaed'>Betaed</span>"
      else
        "<span class='translated'>Translated</span>"
      end
    else
      "<span class='not_translated'>Not translated</span>"
    end    
  end
  
  def namespace_notes(namespace)
    note_count = @current_locale.translation_notes.count(:all, :conditions => {:namespace => namespace}).to_s
    read_link = link_to('Read notes (' + note_count + ')', translation_notes_path(:namespace => namespace))
    add_link = link_to('Add a note', new_translation_note_path(:namespace => namespace))
    read_link + " | " + add_link
  end
  
  def rows_for_words(string)
   words = (string).split(/\S+/).size
   words > 5 ? words/5 : 1
  end

# Enigel Nov. 15 08
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes==0) ? 'less than 1 minute' : '1 minute' unless include_seconds
      case distance_in_seconds
      when 0..5 then "less than 5 seconds"
      when 6..10 then "less than 10 seconds"
      when 11..20 then "less than 20 seconds"
      when 21..40 then "half a minute"
      when 41..59 then "less than a minute"
      else "1 minute"
      end
    when 2..45 then "#{distance_in_minutes} minutes"
    when 46..90 then "1 hour"
    when 90..1440 then "#{(distance_in_minutes.to_f / 60.0).round} hours" 
    when 1441..2880 then "1 day"
    else "#{(distance_in_minutes / 1440).round} days"
    end
  end

def time_ago_in_words(from_time, include_seconds = false)
    
    to_time = Time.now
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes==0) ? 'less than 1 minute ago' : '1 minute ago' unless include_seconds
      case distance_in_seconds
      when 0..5 then "less than 5 seconds ago"
      when 6..10 then "less than 10 seconds ago"
      when 11..20 then "less than 20 seconds ago"
      when 21..40 then "half a minute ago"
      when 41..59 then "less than a minute ago"
      else "1 minute ago"
      end
    when 2..45 then "#{distance_in_minutes} minutes ago" 
    when 46..90 then "1 hour ago"
    when 90..1440 then "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
    when 1441..2880 then "1 day ago"
    else "#{(distance_in_minutes / 1440).round} days ago"
    end
  end

alias distance_of_time_in_words_to_now time_ago_in_words

end
