module TagSetsHelper
  
  def nomination_notes(limit)
    message = ""
    if limit[:fandom] > 0 
      if limit[:character] > 0
        if limit[:relationship] > 0
          message = ts("You can nominate up to %{f} fandoms and up to %{c} characters and %{r} relationships for each one.", 
            :f => limit[:fandom], :c => limit[:character], :r => limit[:relationship])
        else
          message = ts("You can nominate up to %{f} fandoms and up to %{c} characters for each one.", :f => limit[:fandom], :c => limit[:character])
        end
      elsif limit[:relationship] > 0
        message = ts("You can nominate up to %{f} fandoms and up to %{r} relationships for each one.", :f => limit[:fandom], :r => limit[:relationship])
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
  
  
  def noncanonical_info_class(form)
    ((form.object.new_record? || form.object.canonical) ? ' hideme' : '')
  end
  
  def nomination_status(nomination=nil)
    if nomination && nomination.approved
      '<span class="symbol approved" tooltip="This nomination has been approved!"><span>&#x2714;</span></span>'.html_safe
    elsif nomination && nomination.rejected
      '<span class="symbol rejected" tooltip="This nomination was rejected (but an alternate version may have been approved instead)."><span>&#x2718;</span></span>'.html_safe
    else
      '<span class="symbol unreviewed" tooltip="This nomination has not been reviewed yet and can still be changed."><span>&#x2753;</span></span>'.html_safe
    end
  end
  
  def tag_relation_to_list(tag_relation)
    tag_relation.by_name_without_articles.value_of(:name).map {|tagname| content_tag(:li, tagname)}.join("\n").html_safe
  end
  
end
