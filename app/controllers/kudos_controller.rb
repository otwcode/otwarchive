class KudosController < ApplicationController

  cache_sweeper :kudos_sweeper

  skip_before_action :store_location

  def index
    @work = Work.find(params[:work_id])
    @kudos = @work.kudos.includes(pseud: :user).with_pseud
    @guest_kudos_count = @work.kudos.by_guest.count
  end

  def create
    @kudo = Kudo.new(kudo_params)
    if current_user.present?
      @kudo.pseud = current_user.default_pseud
      @kudo.user = current_user
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
          @kudos = @commentable.kudos.with_pseud.includes(pseud: :user).order("created_at DESC")

          render :create, status: :created
        end
      end
    else
      respond_to do |format|
        format.html do
          error_message = "We couldn't save your kudos, sorry!"
          commentable = @kudo.commentable
          if @kudo && @kudo.dup?
            error_message = @kudo.errors.full_messages.first
          end
          if @kudo && @kudo.creator_of_work?
            error_message = "You can't leave kudos on your own work."
          end
          if !current_user.present? && commentable&.restricted?
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
  rescue ActiveRecord::RecordNotUnique => e
    # Uniqueness checks at application level (Rails validations) are inherently
    # prone to race conditions. If we pass Rails validations but get rejected
    # by database unique indices, use the usual duplicate error message.
    #
    # https://api.rubyonrails.org/v5.1/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of-label-Concurrency+and+integrity
    if e.message =~ /Mysql2?::Error: Duplicate entry/i
      flash[:comment_error] = ts("You have already left kudos here. :)")
      redirect_to request.referer
      return
    end

    # If we get unknown errors, let them propagate normally.
    raise
  end

  private

  def kudo_params
    params.require(:kudo).permit(:commentable_id, :commentable_type)
  end
end
