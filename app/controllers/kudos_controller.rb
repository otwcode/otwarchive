class KudosController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  cache_sweeper :kudos_sweeper

  skip_before_filter :store_location

  def create
    #below if block validates that kudos is only being left on a work, (Stephanie 9-17-2013)
    if params[:kudo][:kudosable_type] == 'Work'
      @commentable = Work.find(params[:kudo][:kudosable_id])
    else
      temp_chapter = Chapter.find(params[:kudo][:kudosable_id])
      @commentable = temp_chapter.work
    end

    unless @commentable
      flash[:error] = ts("What did you want to leave kudos on?")
      redirect_to root_path and return
    end

    pseud = logged_in? ? current_user.default_pseud : nil
    if current_user && current_user.is_author_of?(@commentable)
      flash[:comment_error] = ts("You can't leave kudos for yourself. :)")
    else
      ip_address = logged_in? ? nil : request.remote_ip
      if (@kudo = Kudo.new(:commentable => @commentable, :pseud => pseud, :ip_address => ip_address)) && @kudo.save
        flash[:comment_notice] = ts("Thank you for leaving kudos!")
      else
        flash[:comment_error] = @kudo ? @kudo.errors.full_messages.map {|msg| msg.gsub(/^(.+)\^/, '')}.join(", ") : ts("We couldn't save your kudos, sorry!")
      end
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
