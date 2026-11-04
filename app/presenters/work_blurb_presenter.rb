class WorkBlurbPresenter
  def initialize(works, force_reveal: false, blurb: true)
    @works = Array(works).compact
    @force_reveal = force_reveal
    @blurb = blurb
  end

  def render_in(view_context)
    view_context.safe_join(works.map { |work| render_work(view_context, work) })
  end

  private

  attr_reader :works

  def render_work(view_context, work)
    if blurb?
      render_blurb(view_context, work)
    else
      render_module(view_context, work)
    end
  end

  def render_blurb(view_context, work)
    view_context.render(
      "works/work_blurb",
      work: work,
      work_module_html: render_module(view_context, work)
    )
  end

  def render_module(view_context, work)
    view_context.render(module_partial_path(view_context, work), work: work)
  end

  def module_partial_path(view_context, work)
    use_mystery_blurb?(view_context, work) ? "works/mystery_blurb" : "works/work_module"
  end

  def use_mystery_blurb?(view_context, work)
    work.unrevealed? && !viewer_owns_work?(view_context, work) && !force_reveal?
  end

  def viewer_owns_work?(view_context, work)
    view_context.is_author_of?(work)
  end

  def force_reveal?
    @force_reveal
  end

  def blurb?
    @blurb
  end
end
