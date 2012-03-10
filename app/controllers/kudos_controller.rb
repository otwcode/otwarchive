class KudosController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def create
    @commentable = params[:kudo][:kudosable_type] == 'Work' ? Work.find(params[:kudo][:kudosable_id]) : Chapter.find(params[:kudo][:kudosable_id])
    unless @commentable
      flash[:error] = ts("What did you want to leave kudos on?")
      redirect_to root_path and return
    end

    pseud = logged_in? ? current_user.default_pseud : nil
    if current_user && current_user.is_author_of?(@commentable)
      flash[:comment_error] = ts("You can't leave kudos for yourself. :)")
    else
      ip_address = logged_in? ? nil : request.remote_ip
      unless (@kudo = Kudo.new(:commentable => @commentable, :pseud => pseud, :ip_address => ip_address)) && @kudo.save
        flash[:comment_error] = @kudo ? @kudo.errors.full_messages.map {|msg| msg.gsub(/^(.+)\^/, '')}.join(", ") : ts("We couldn't save your kudos, sorry!")
      end
    end
    if request.referer.match(/static/)
      # came here from a static page
      # so go to the kudos page if you can, instead of reloading the full work
      if @kudo && @kudo.id # saved
        redirect_to kudo_path(@kudo, :url => request.referer)
      else
        redirect_to :controller => @commentable.class.to_s.underscore.pluralize, :action => :show, :id => @commentable.id, :anchor => "comments"
      end
    else
      # redirect to what the user was actually reading - chapter or work - when they left kudos
      redirect_to :controller => params[:commentable_controller], :action => :show, :id => params[:commentable_id], :view_full_work => params[:view_full_work], :page => params[:page], :anchor => "comments"
    end
  end

  def show
    @kudo = Kudo.find(params[:id])
    @referrer = params[:url].blank? ? url_for(@kudo.commentable) : params[:url]
  end

end
