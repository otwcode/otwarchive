class TagWranglingsController < ApplicationController
  cache_sweeper :tag_sweeper

  before_filter :check_user_status
  before_filter :check_permission_to_wrangle

  def index
    @counts = {}
    [Fandom, Character, Relationship, Freeform].each do |klass|
      @counts[klass.to_s.downcase.pluralize.to_sym] = klass.unwrangled.in_use.count
    end
    unless params[:show].blank?
      params[:sort_column] = 'created_at' if !valid_sort_column(params[:sort_column], 'tag')
      params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
      sort = params[:sort_column] + " " + params[:sort_direction]
      sort = sort + ", name ASC" if sort.include?('taggings_count')
      if params[:show] == "fandoms"
        @media_names = Media.by_name.value_of(:name)
        @page_subtitle = ts("fandoms")
        @tags = Fandom.unwrangled.in_use.order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
      else # by fandom
        klass = params[:show].classify.constantize
        @tags = klass.unwrangled.in_use.order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
      end
    end
  end

  def wrangle
    params[:page] = '1' if params[:page].blank?
    params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
    params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
    options = {show: params[:show], page: params[:page], sort_column: params[:sort_column], sort_direction: params[:sort_direction]}

    not_saved_canonicals = []
    error_messages = []

    # make tags canonical if allowed
    if params[:canonicals].present? && params[:canonicals].is_a?(Array)
      tags = Tag.find_with_ids(params[:canonicals])

      tags.each do |tag_to_canonicalize|
        unless tag_to_canonicalize.update_attributes(canonical: true)
          not_saved_canonicals << tag_to_canonicalize
        end
      end
    end

    if params[:media] && !params[:selected_tags].blank?
      options.merge!(media: params[:media])
      @media = Media.find_by_name(params[:media])
      @fandoms = Fandom.find(params[:selected_tags])
      @fandoms.each { |fandom| fandom.add_association(@media) }
    elsif params[:character_string] && !params[:selected_tags].blank?
      options.merge!(character_string: params[:character_string], fandom_string: params[:fandom_string])
      @character = Character.find_by_name(params[:character_string])

      if @character && @character.canonical?
        @tags = Tag.find(params[:selected_tags])
        @tags.each { |tag| tag.add_association(@character) }
        flash[:notice] = "#{@tags.length} relationships were wrangled to #{params[:character_string]}."

        redirect_to tag_wranglings_path(options) and return
      else
        flash[:error] = "#{params[:character_string]} is not a canonical character."

        redirect_to tag_wranglings_path(options) and return
      end
    elsif params[:fandom_string].present? && params[:selected_tags].present? && !params[:selected_tags].empty?
      options.merge!(fandom_string: params[:fandom_string])

      canonical_fandoms, noncanonical_fandom_names = [], []
      fandom_names = params[:fandom_string].split(',').map(&:squish)

      fandom_names.each do |fandom_name|
        if (fandom = Fandom.find_by_name(fandom_name)).try(:canonical?)
          canonical_fandoms << fandom
        else
          noncanonical_fandom_names << fandom_name
        end
      end

      if canonical_fandoms.present?
        tags = Tag.find_with_ids(params[:selected_tags])

        tags.each do |tag_to_wrangle|
          canonical_fandoms.each do |fandom|
            tag_to_wrangle.add_association(fandom)
          end
        end
      end

      if noncanonical_fandom_names.present?
        error_messages << ts('The following names are not canonical fandoms: %{noncanonical_fandom_names}.', noncanonical_fandom_names: noncanonical_fandom_names)
      end
    end

    error_messages << ts('The following tags couldn\'t be made canonical: %{tags_not_saved}', tags_not_saved: not_saved_canonicals.collect(&:name).join(', ')) unless not_saved_canonicals.empty?

    flash[:error] = error_messages.join('\n') unless error_messages.empty?
    flash[:notice] = 'Tags were successfully wrangled!' if error_messages.empty?

    redirect_to tag_wranglings_path(options)
  end

  def discuss
    @comments = Comment.where(:commentable_type => 'Tag').order('updated_at DESC').paginate(:page => params[:page])
  end

end
