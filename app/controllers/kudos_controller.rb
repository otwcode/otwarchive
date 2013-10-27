class KudosController < ApplicationController
  
  cache_sweeper :kudos_sweeper

  def create
    @kudo = Kudo.new(params[:kudo])
    if current_user.present?
      @kudo.pseud = current_user.default_pseud
    else
      @kudo.ip_address = request.remote_ip
    end

    respond_to do |format|
      format.html do
        if @kudo.save
          flash[:comment_notice] = ts("Thank you for leaving kudos!")
        else
          msg = @kudo.dup? ? "You have already left kudos here. :)" : "We couldn't save your kudos, sorry!"
          flash[:comment_error] = ts(msg)
        end
        redirect_to request.referer
      end
      format.js do
        if @kudo.save
          render json: @kudo, status: :created
        else
          render json: { errors: @kudo.errors }
        end
      end
    end
  end

end
