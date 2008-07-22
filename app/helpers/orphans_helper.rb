module OrphansHelper
 
  # Renders the appropriate partial based on the class of object to be orphaned
  def render_orphan_partial(to_be_orphaned)
    if to_be_orphaned.is_a?(Work)
      render :partial => 'orphans/orphan_work', :locals => {:work => to_be_orphaned}
    elsif to_be_orphaned.is_a?(Pseud)
      render :partial => 'orphans/orphan_pseud', :locals => {:pseud => to_be_orphaned}  
    else
      render :partial => 'orphans/orphan_user'
    end
  end
end
