class TranslationController < ApplicationController
  #permit('translator',
          #:permission_denied_redirection => {:controller => :works, :action => :index },
          #:permission_denied_message => 'Sorry, the page you have requested is for translators only! Please contact an admin if you think you should have access.' )
  
  def index    
    @title = "Translation Interface"
    if !Locale.language
       default_loc = Locale.new(ArchiveConfig.BASE_LANGUAGE)
       Locale.set default_loc
    end
    
    @view_translations = ViewTranslation.paginate(:all, 
                                              :conditions => [ 'built_in IS NULL AND language_id = ?', 
    Locale.language.id ], 
    :order => 'id', :page => params[:page])                                                
  end
 
# Shows only strings which have not yet been translated  
  def hide_translated
    if !Locale.language
      default_loc = Locale.new(ArchiveConfig.BASE_LANGUAGE)
      Locale.set default_loc
    end
    
    @view_translations = ViewTranslation.paginate(:all, :conditions => [ 'built_in IS NULL AND text IS NULL AND language_id = ?',
    Locale.language.id ], :order => 'id', :page => params[:page])
  end
  
  def translation_text
    @translation = ViewTranslation.find(params[:id])
    render :text => @translation.text || ""  
  end

  def set_translation_text
    @translation = ViewTranslation.find(params[:id])
    previous = @translation.text
    @translation.text = params[:translation]
    @translation.text = previous unless @translation.save
    redirect_to :action => 'index'
  end
  
  # Search all of our application to harvest translateable strings which have
  # not yet been viewed. Slow, so should not be done automatically.  
  def get_translatable_strings
    @strs = []
    allowed = ' \w0-9%:;@&#<>\/\\\?\!\+\)\(-=\*'
    regexp = Regexp.new('[\"](['+allowed+'\']*)[\"]\.t|[\'](['+allowed+'\"]*)[\']\.t')
    Dir.glob("#{RAILS_ROOT}/app/views/**/*.erb").collect do |f|
      @strs << File.read(f).scan(regexp)
    end
    @new_strs=Array.new
    @strs=@strs.flatten.uniq
    0.upto @strs.size-1 do |i|
      if @strs[i] then
        @strs[i].each do |str|
          @new_strs << str
        end
      end
    end
    @strs = []
    Dir.glob("#{RAILS_ROOT}/app/controllers/**/*.rb").collect do |f|
      @strs << File.read(f).scan(regexp)
    end
    @strs=@strs.flatten.uniq
    0.upto @strs.size-1 do |i|
      if @strs[i] then
        @strs[i].each do |str|
          @new_strs << str
        end
      end
    end
    @new_strs=@new_strs.uniq
    @new_strs.each do |str|
      str.to_s.translate
    end
    flash[:notice] = "Strings collected".t
    #Now redirects to back because it could be coming from index or hide_translated
    redirect_to :back
  end
end
