class Static::MediaController < Static::BaseController
  caches_page :show
  def show
    @medium = Media.find_by_name(params[:id])
    @fandoms = @medium.fandoms.where(:canonical => true) if @medium
    @fandoms = (@fandoms || Fandom).where("filter_taggings.inherited = 0").
                for_collections([@collection]).
                select("tags.*, count(tags.id) as count").
                group(:id).
                order("TRIM(LEADING 'a ' FROM TRIM(LEADING 'an ' FROM TRIM(LEADING 'the ' FROM LOWER(name))))")
    @fandoms_by_letter = @fandoms.group_by {|f| f.name.sub(/^(the|a|an)\s+/i, '')[0].upcase}
    render :action => 'static/fandoms/index'
  end
end
