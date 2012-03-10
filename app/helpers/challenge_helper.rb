module ChallengeHelper
  def prompt_tags(prompt)
    details = content_tag(:h6, ts("Tags"), :class => "landmark heading")
    TagSet::TAG_TYPES.each do |type|
      if prompt && prompt.tag_set && !prompt.tag_set.with_type(type).empty?
        details += content_tag(:ul, tag_link_list(prompt.tag_set.with_type(type), link_to_works=true), :title => type, :class => "#{type} type tags commas")
      end
    end
    details
  end      
  
  # generate the display value for the claim
  def claim_title(claim)
    claim.title.html_safe + link_to(ts(" (Details)"), collection_prompt_path(claim.collection, claim.request_prompt), :target => "_blank", :class => "toggle")
  end
  
end