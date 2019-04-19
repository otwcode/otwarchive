module CommonCreatership
  extend ActiveSupport::Concern

# set the author attributes
  def set_author_attributes
    controller = params[:controller].singularize.to_sym
    # params[:work] is required for every if statement below, so it is hoisted to
    # the top to avoid repeating ourselves.
    return unless params[controller]

    # stuff co-authors into author attributes too so we won't lose them
    if params[controller][:author_attributes] && params[controller][:author_attributes][:coauthors]
      params[controller][:author_attributes][:ids].concat(params[controller][:author_attributes][:coauthors]).uniq!
    end

    # if we don't have author_attributes[:ids], which shouldn't be allowed to happen
    # (this can happen if a user with multiple pseuds decides to unselect *all* of them)
    sorry = { :work => ts("You haven't selected any pseuds for this work. Please use Remove Me As Author or consider orphaning your work instead if you do not wish to be associated with it anymore."),
              :series=> ts("Sorry, you cannot remove yourself entirely as an author of a series right now."),
              :chapter => ts("you cannot remove yourself entirely as an author of a chapter right now. ") }[controller]

    if !params[controller][:author_attributes] || !params[controller][:author_attributes][:ids]
      flash.now[:notice] = sorry
      params[controller][:author_attributes] ||= {}
      params[controller][:author_attributes][:ids] = [current_user.default_pseud.id]
    end

    # stuff new bylines into author attributes to be parsed by the work model
    if params[:pseud] && params[:pseud][:byline] && params[:pseud][:byline] != ''
      params[controller][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ''
    end
  end

end