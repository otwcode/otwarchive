require "spec_helper"

class WorkBlurbPresenterViewContext
  attr_reader :renders

  def initialize(owned_works: [])
    @owned_works = owned_works
    @renders = []
  end

  def render(partial, locals)
    @renders << [partial, locals]
    partial
  end

  def safe_join(parts)
    parts.join
  end

  def is_author_of?(work)
    @owned_works.include?(work)
  end
end

RSpec.describe WorkBlurbPresenter do
  let(:revealed_work) { instance_double(Work, unrevealed?: false) }
  let(:unrevealed_work) { instance_double(Work, unrevealed?: true) }

  it "renders the work blurb shell by default" do
    view_context = WorkBlurbPresenterViewContext.new

    described_class.new(revealed_work).render_in(view_context)

    expect(view_context.renders).to eq([
      ["works/work_module", { work: revealed_work }],
      ["works/work_blurb", { work: revealed_work, work_module_html: "works/work_module" }]
    ])
  end

  it "renders only the work module when blurb is false" do
    view_context = WorkBlurbPresenterViewContext.new

    described_class.new(revealed_work, blurb: false).render_in(view_context)

    expect(view_context.renders).to eq([
      ["works/work_module", { work: revealed_work }]
    ])
  end

  it "uses the mystery blurb for unrevealed works the viewer does not own" do
    view_context = WorkBlurbPresenterViewContext.new

    described_class.new(unrevealed_work).render_in(view_context)

    expect(view_context.renders.first).to eq([
      "works/mystery_blurb",
      { work: unrevealed_work }
    ])
  end

  it "uses the full work module for unrevealed works the viewer owns" do
    view_context = WorkBlurbPresenterViewContext.new(owned_works: [unrevealed_work])

    described_class.new(unrevealed_work).render_in(view_context)

    expect(view_context.renders.first).to eq([
      "works/work_module",
      { work: unrevealed_work }
    ])
  end

  it "uses the full work module when forced to reveal" do
    view_context = WorkBlurbPresenterViewContext.new

    described_class.new(unrevealed_work, force_reveal: true).render_in(view_context)

    expect(view_context.renders.first).to eq([
      "works/work_module",
      { work: unrevealed_work }
    ])
  end

  it "renders each work in a collection" do
    view_context = WorkBlurbPresenterViewContext.new

    described_class.new([revealed_work, unrevealed_work]).render_in(view_context)

    expect(view_context.renders.map(&:first)).to eq([
      "works/work_module",
      "works/work_blurb",
      "works/mystery_blurb",
      "works/work_blurb"
    ])
  end
end
