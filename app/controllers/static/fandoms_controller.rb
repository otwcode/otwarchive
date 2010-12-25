class Static::FandomsController < Static::BaseController
  caches_page :index, :show

  def index
    @fandoms = Fandom.where("filter_taggings.inherited = 0").
                          for_collections([@collection]).
                          select("tags.*, count(tags.id) as count").
                          group(:id).
                          order("TRIM(LEADING 'a ' FROM TRIM(LEADING 'an ' FROM TRIM(LEADING 'the ' FROM LOWER(name))))")
    @fandoms_by_letter = @fandoms.group_by {|f| f.name.sub(/^(the|a|an)\s+/i, '')[0].upcase}
  end

  def show
    @fandom = Fandom.find_by_name(params[:id])
    @works = Work.with_all_filters([@fandom]).
                      in_collection(@collection).
                      visible_to_all.
                      order(:title)
  end
end
