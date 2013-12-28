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
        message = ts("You can nominate up to %{ff} additional tags.", :ff => limit[:freeform])
      else
        message += ts(" You can also nominate up to %{ff} additional tags.", :ff => limit[:freeform])
      end
    end
    
    message
  end
  
  
  def noncanonical_info_class(form)
    ((form.object.new_record? || form.object.canonical) ? ' hideme' : '')
  end
  
  def nomination_status(nomination=nil)
    if nomination && nomination.approved
      '<span class="symbol approved" tooltip="This nomination has been approved!"><span>&#10004;</span></span>'.html_safe
    elsif nomination && nomination.rejected
      '<span class="symbol rejected" tooltip="This nomination was rejected (but another version may have been approved instead)."><span>&#10006;</span></span>'.html_safe
    else
      '<span class="symbol unreviewed" tooltip="This nomination has not been reviewed yet and can still be changed."><span>?!</span></span>'.html_safe
    end
  end
  
#BACK END, I attempted to put titles in but it's rendering as oldtitle
  def nomination_status_span(nom)
    status = "nonexistent"
    tooltip = ts("This tag has never been used on the archive before. Check the spelling!")
    title = ts("nonexistent tag")
    case
    when nom.canonical
      if nom.parented
        status = "canonical"
        tooltip = ts("This is a canonical archive tag.")
        title = ts("canonical tag")
      else
        status = "unparented"
        tooltip = ts("This is a canonical archive tag but not associated with the fandom.")
        title = ts("canonical tag without parent")
      end
    when nom.exists
      status = "unwrangled"
      tooltip = ts("This is not an official archive tag.")
      title = ts("unofficial tag")
    end
    
    return "<span class='nomination #{status}' title='#{title}' tooltip='#{tooltip}'>".html_safe
  end
  
  def tag_relation_to_list(tag_relation)
    tag_relation.by_name_without_articles.value_of(:name).map {|tagname| content_tag(:li, tagname)}.join("\n").html_safe
  end
  
end
