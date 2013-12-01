class KudosController < ApplicationController
  
  cache_sweeper :kudos_sweeper

  skip_before_filter :store_location

  def create
    @kudo = Kudo.new(params[:kudo])
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
          msg = @kudo.dup? ? "You have already left kudos here. :)" : "We couldn't save your kudos, sorry!"
          flash[:comment_error] = ts(msg)

          redirect_to request.referer and return
        end

        format.js do
          render json: { errors: @kudo.errors }, status: :unprocessable_entity
        end
      end
    end
  end

end
