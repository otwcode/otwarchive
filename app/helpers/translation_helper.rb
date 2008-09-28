module TranslationHelper
  
  def rows_for_words(string)
   words = (string).split(/\S+/).size
   words > 5 ? words/5 : 1
  end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes==0) ? 'less than 1 minute ago'.t : '1 min ago'.t unless include_seconds
      case distance_in_seconds
      when 0..5 then "less than %d seconds".t / 5
      when 6..10 then "less than %d seconds".t / 10
      when 11..20 then "less than %d seconds".t / 20
      when 21..40 then "half a minute".t
      when 41..59 then "less than a minute".t
      else "1 minute".t
      end
    when 2..45 then "%d min".t / distance_in_minutes
    when 46..90 then "1 hour ago".t
    when 90..1440 then "%d hours ago".t / (distance_in_minutes.to_f / 60.0).round
    when 1441..2880 then "1 day ago".t
    else "%d days ago".t / (distance_in_minutes / 1440).round
    end
  end

end
