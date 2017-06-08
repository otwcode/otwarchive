module OrphansHelper
 
  # Renders the appropriate partial based on the class of object to be orphaned
  def render_orphan_partial(orphans)
    to_be_orphaned = orphans.first
    if to_be_orphaned.is_a?(Work)
      render 'orphans/orphan_work', works: orphans
    elsif to_be_orphaned.is_a?(Series)
      render 'orphans/orphan_series', series: to_be_orphaned 
    elsif to_be_orphaned.is_a?(Pseud)
      render 'orphans/orphan_pseud', pseud: to_be_orphaned
    else
      render 'orphans/orphan_user'
    end
  end
end
