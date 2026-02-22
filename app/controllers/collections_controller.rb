class CollectionsController < ApplicationController
  before_action :users_only, only: [:new, :edit, :create, :update]
  before_action :load_collection_from_id, only: [:show, :edit, :update, :destroy, :confirm_delete]
  before_action :collection_owners_only, only: [:edit, :update, :destroy, :confirm_delete]
  before_action :check_user_status, only: [:new, :create, :edit, :update, :destroy]
  before_action :validate_challenge_type
  before_action :check_parent_visible, only: [:index]
  cache_sweeper :collection_sweeper

  # Lazy fix to prevent passing unsafe values to eval via challenge_type
  # In both CollectionsController#create and CollectionsController#update there are a vulnerable usages of eval
  # For now just make sure the values passed to it are safe
  def validate_challenge_type
    if params[:challenge_type] and not ["", "GiftExchange", "PromptMeme"].include?(params[:challenge_type])
      return render status: :bad_request, text: "invalid challenge_type"
    end
  end

  def load_collection_from_id
    @collection = Collection.find_by(name: params[:id])
    unless @collection
        raise ActiveRecord::RecordNotFound, "Couldn't find collection named '#{params[:id]}'"
    end
  end

  def check_parent_visible
    return unless params[:work_id] && (@work = Work.find_by(id: params[:work_id]))

    check_visibility_for(@work)
  end

  def index
    if params[:work_id]
      @work = Work.find(params[:work_id])
      @collections = @work.approved_collections
        .by_title
        .for_blurb
        .paginate(page: params[:page])
    elsif params[:collection_id]
      @collection = Collection.find_by!(name: params[:collection_id])
      @search = CollectionSearchForm.new({ parent_id: @collection.id, sort_column: "title.keyword" }.merge(page: params[:page]))
      @collections = @search.search_results.scope(:for_search)
      flash_search_warnings(@collections)
      @page_subtitle = t(".subcollections_page_title", collection_title: @collection.title)
    elsif params[:user_id]
      @sort_and_filter = true
      @user = User.find_by!(login: params[:user_id])
      @search = CollectionSearchForm.new(collection_filter_params.merge({ maintainer_id: @user.id, sort_column: "title.keyword" }.merge(page: params[:page])))
      @collections = @search.search_results.scope(:for_search)
      flash_search_warnings(@collections)
      @page_subtitle = ts("%{username} - Collections", username: @user.login)
    else
      @sort_and_filter = true
      @search = CollectionSearchForm.new(collection_filter_params.merge(page: params[:page]))
      @collections = @search.search_results.scope(:for_search)
      flash_search_warnings(@collections)
    end
  end

  # display challenges that are currently taking signups
  def list_challenges
    @page_subtitle = "Open Challenges"
    @hide_dashboard = true

    @challenge_collections = (CollectionSearchForm.new(challenge_type: "GiftExchange", signup_open: true, sort_column: "signups_close_at", page: 1, per_page: 15).search_results.to_a +
                             CollectionSearchForm.new(challenge_type: "PromptMeme", signup_open: true, sort_column: "signups_close_at", page: 1, per_page: 15).search_results.to_a)
  end

  def list_ge_challenges
    @page_subtitle = "Open Gift Exchange Challenges"
    @challenge_collections = CollectionSearchForm.new(challenge_type: "GiftExchange", signup_open: true, sort_column: "signups_close_at", page: 1, per_page: 15).search_results
  end

  def list_pm_challenges
    @page_subtitle = "Open Prompt Meme Challenges"
    @challenge_collections = CollectionSearchForm.new(challenge_type: "PromptMeme", signup_open: true, sort_column: "signups_close_at", page: 1, per_page: 15).search_results
  end

  def show
    @page_subtitle = @collection.title

    if @collection.collection_preference.show_random? || params[:show_random]
      # show a random selection of works/bookmarks
      @works = WorkQuery.new(
        collection_ids: [@collection.id], show_restricted: is_registered_user?
      ).sample(count: ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)

      @bookmarks = BookmarkQuery.new(
        collection_ids: [@collection.id], show_restricted: is_registered_user?
      ).sample(count: ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    else
      # show recent
      @works = WorkQuery.new(
        collection_ids: [@collection.id], show_restricted: is_registered_user?,
        sort_column: "revised_at",
        per_page: ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD
      ).search_results

      @bookmarks = BookmarkQuery.new(
        collection_ids: [@collection.id], show_restricted: is_registered_user?,
        sort_column: "created_at",
        per_page: ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD
      ).search_results
    end
  end

  def new
    @hide_dashboard = true
    @collection = Collection.new
    if params[:collection_id] && (@collection_parent = Collection.find_by(name: params[:collection_id]))
      @collection.parent_name = @collection_parent.name
    end
  end

  def edit
  end

  def create
    @hide_dashboard = true
    @collection = Collection.new(collection_params)

    # add the owner
    owner_attributes = []
    (params[:owner_pseuds] || [current_user.default_pseud_id]).each do |pseud_id|
      pseud = Pseud.find(pseud_id)
      owner_attributes << {pseud: pseud, participant_role: CollectionParticipant::OWNER} if pseud
    end
    @collection.collection_participants.build(owner_attributes)

    if @collection.save
      flash[:notice] = ts('Collection was successfully created.')
      unless params[:challenge_type].blank?
        if params[:challenge_type] == "PromptMeme"
          redirect_to new_collection_prompt_meme_path(@collection) and return
        elsif params[:challenge_type] == "GiftExchange"
          redirect_to new_collection_gift_exchange_path(@collection) and return
        end
      else
        redirect_to collection_path(@collection)
      end
    else
      @challenge_type = params[:challenge_type]
      render action: "new"
    end
  end

  def update
    if @collection.update(collection_params)
      flash[:notice] = ts('Collection was successfully updated.')
      if params[:challenge_type].blank?
        if @collection.challenge
          # trying to destroy an existing challenge
          flash[:error] = ts("Note: if you want to delete an existing challenge, please do so on the challenge page.")
        end
      else
        if @collection.challenge
          if @collection.challenge.class.name != params[:challenge_type]
            flash[:error] = ts("Note: if you want to change the type of challenge, first please delete the existing challenge on the challenge page.")
          else
            if params[:challenge_type] == "PromptMeme"
              redirect_to edit_collection_prompt_meme_path(@collection) and return
            elsif params[:challenge_type] == "GiftExchange"
              redirect_to edit_collection_gift_exchange_path(@collection) and return
            end
          end
        else
          if params[:challenge_type] == "PromptMeme"
            redirect_to new_collection_prompt_meme_path(@collection) and return
          elsif params[:challenge_type] == "GiftExchange"
            redirect_to new_collection_gift_exchange_path(@collection) and return
          end
        end
      end
      redirect_to collection_path(@collection)
    else
      render action: "edit"
    end
  end

  def confirm_delete
  end

  def destroy
    @hide_dashboard = true
    @collection = Collection.find_by(name: params[:id])
    begin
      @collection.destroy
      flash[:notice] = ts("Collection was successfully deleted.")
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end
    redirect_to(collections_path)
  end

  private

  def collection_filter_params
    params.permit(:commit, :user_id, collection_search: [
      :title, :challenge_type, :moderated, :multifandom, :closed, :tag,
      :sort_column, :sort_direction
    ])[:collection_search] || {}
  end

  def collection_params
    params.require(:collection).permit(
      :name, :title, :email, :header_image_url, :description,
      :parent_name, :challenge_type, :icon, :delete_icon,
      :icon_alt_text, :icon_comment_text, :tag_string, :multifandom,
      collection_profile_attributes: [
        :id, :intro, :faq, :rules,
        :gift_notification, :assignment_notification
      ],
      collection_preference_attributes: [
        :id, :moderated, :closed, :unrevealed, :anonymous,
        :gift_exchange, :show_random, :prompt_meme, :email_notify
      ]
    )
  end
end
