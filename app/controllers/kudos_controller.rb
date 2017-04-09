class KudosController < ApplicationController

  cache_sweeper :kudos_sweeper

  skip_before_filter :store_location

  def index
    @work = Work.find(params[:work_id])
    @kudos = @work.kudos.includes(:pseud => :user).with_pseud
    @guest_kudos_count = @work.kudos.by_guest.count
  end

  def create
    @kudo = Kudo.new(kudo_params)
    if current_user.present?
      @kudo.pseud = current_user.default_pseud
    else
      @kudo.ip_address = request.remote_ip
    end

    if @kudo.save
      respond_to do |format|
        format.html do
          flash[:comment_notice] = ts("Thank you for leaving kudos!")

          redirect_to request.referer and return
        end

        format.js do
          @commentable = @kudo.commentable
          @kudos = @commentable.kudos.with_pseud.includes(:pseud => :user).order("created_at DESC")

          render :create, status: :created
        end
      end
    else
      respond_to do |format|
        format.html do
          error_message = "We couldn't save your kudos, sorry!"
          commentable = @kudo.commentable
          if @kudo.dup?
            error_message = 'You have already left kudos here. :)'
          end
          if @kudo.creator_of_work?
            error_message = "You can't leave kudos on your own work."
          end
          if !current_user.present? && commentable.restricted?
            error_message = "You can't leave guest kudos on a restricted work."
          end
          flash[:comment_error] = ts(error_message)
          redirect_to request.referer and return
        end

        format.js do
          render json: { errors: @kudo.errors }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def kudo_params
    params.require(:kudo).permit(:commentable_id, :commentable_type)
  end
end
