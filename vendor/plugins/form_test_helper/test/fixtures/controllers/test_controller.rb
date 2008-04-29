class TestController < ActionController::Base
  require 'ostruct'
    
  def index
    render :text => 'foo'
  end
  
  verify :method => :post, :only => [ :create ],
            :redirect_to => { :action => :index }
  def create
    if request.xhr?
      render :text => 'created with xhr'
     else
      render :text => 'created'
    end
  end
  
  verify :method => :delete, :only => [ :destroy ],
            :redirect_to => { :action => :index }
  def destroy
    render :text => 'destroyed'
  end
  
  def redirect_to_back
    redirect_to :back
  end

  def response_with=(content)
    @content = content
  end

  def response_with(&block)
    @update = block
  end
 
  def rhtml
    @article = OpenStruct.new("published" => false, "written" => true)
    @book = OpenStruct.new
    render :inline=>(@content || params[:content]), :layout=>false, :content_type=>Mime::HTML
    @content = nil
  end

  def html()
    render :text=>@content, :layout=>false, :content_type=>Mime::HTML
    @content = nil
  end

  def rjs()
    render :update do |page|
      @update.call page
    end
    @update = nil
  end

  def rescue_action(e)
    raise e
  end

end