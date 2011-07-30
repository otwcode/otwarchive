module TagSetNominationsHelper
  
  def nomination_notes(limit)
    message = ""
    if limit[:fandom] > 0 
      if limit[:character] > 0
        if limit[:relationship] > 0
          message = ts("You can nominate up to %{f} fandoms and up to %{c} characters and %{r} relationships for each one.", 
            :f => limit[:fandom], :c => limit[:character], :r => limit[:relationship])
        else
          message = ts("You can nominate up to %{f} fandoms and up to %{c} characters for each one", :f => limit[:fandom], :c => limit[:character])
        end
      elsif limit[:relationship] > 0
        message = ts("You can nominate up to %{f} fandoms and up to %{r} relationships for each one", :f => limit[:fandom], :r => limit[:relationship])
      else
        message = ts("You can nominate up to %{f} fandoms.", :f => limit[:fandom])
      end
    else
      if limit[:character] > 0
        if limit[:relationship] > 0
          message = ts("You can nominate up to %{c} characters and %{r} relationships.", :c => limit[:character], :r => limit[:relationship])
        else
          message = ts("You can nominate up to %{c} characters.", :c => limit[:character])
        end
      elsif limit[:relationship] > 0
        message = ts("You can nominate up to %{r} relationships.", :r => limit[:relationship])
      end
    end
    
    if limit[:freeform] > 0
      if message.blank?
        message = ts("You can nominate up to %{ff} freeform tags.", :ff => limit[:freeform])
      else
        message += ts(" You can also nominate up to %{ff} freeform tags.", :ff => limit[:freeform])
      end
    end
    
    message
  end
  
end
