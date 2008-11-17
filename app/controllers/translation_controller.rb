require 'strscan'
class TranslationController < ApplicationController
  permit "translator", :permission_denied_message => "Sorry, the page you tried to access is for authorized translators only.".t
  before_filter :check_user_status
    
  def translation_text
    @translation = ViewTranslation.find(params[:id])
    render :text => @translation.text || ""  
  end

  def set_translation_text
    translation = ViewTranslation.find(params[:id])
    unless translation
      flash[:error] = "We couldn't find the string you were trying to translate."
    else
      Locale.set_translation(translation.tr_key, params[:translation])
    end
    redirect_to :back
  end
  
  def translate
    @controller_to_translate = params[:controller_to_translate]
    @action_to_translate = params[:action_to_translate]
    @url_to_translate = request.env['HTTP_REFERER']
    
    @strs = []
    
    # find all the view files that this particular controller and action would use
    files = find_view_files(@controller_to_translate, @action_to_translate)
    files.each do |file|
      @strs += find_translateable_strings_in_file(file)
    end
        
    # find all the strings used in this action
    controller_file = "#{RAILS_ROOT}/app/controllers/#{@controller_to_translate}_controller.rb"
    controller_text = File.read(controller_file)
    controller_scanner = StringScanner.new(controller_text)
    controller_scanner.skip_until(Regexp.new("/^\s*def #{@action_to_translate}/"))
    action_text = controller_scanner.scan_until(Regexp.new("/^\s*end\s*$/"))
    if (action_text)
      @strs += action_text.scan(get_translateable_string_regexp)
    end

    # squash everything down, get rid of the nils, and any duplication
    @strs = @strs.flatten.compact.uniq

    # make sure there is a ViewTranslation object for each string in this language
    # by forcibly translating them right now even if they aren't appearing in this
    # particular page.
    @strs.each do |str|
      str.translate
    end
    
    @translations = ViewTranslation.find(:all, 
                                         :conditions => [ 'language_id = ? AND tr_key in (?)', Locale.language.id, @strs ])
                                         
    @translations.sort! do |a,b| 
      if a.text.nil? != b.text.nil?
        return a.text.nil? ? 1 : -1
      else 
        if @strs.index(a.tr_key) && @strs.index(b.tr_key)
          return  @strs.index(a.tr_key) <=> @strs.index(b.tr_key)
        else
          if @strs.index(a.tr_key)
            return 1
          elsif @strs.index(b.tr_key)
            return -1
          else
            return 0
          end
        end
      end
    end
                                         
  end
  
  # Find all the view partials invoked within this file
  def find_view_files(controller_name, action_name)
    root_view = "#{RAILS_ROOT}/app/views/#{controller_name}/#{action_name}.html.erb"
    files = [root_view]
    unscanned = [root_view]
    regexp_for_partials = Regexp.new(':partial\s*=>\s*[\']([^,\']*)[\']|:partial\s*=>\s*[\"]([^,\"]*)[\"]')
    while !unscanned.empty?
      partialnames = File.read(unscanned.shift).scan(regexp_for_partials).flatten.uniq
      partialnames.each do |partialname|
        next if partialname.nil?
        if partialname.match(/(.*)\/(.*)/)
          partialname = "#{$1}/_#{$2}"
        else
          partialname = "#{controller_name}/_#{partialname}"
        end
        partial = "#{RAILS_ROOT}/app/views/#{partialname}.html.erb"
        if (files & [partial]).empty?
          files << partial
          unscanned << partial
        end
      end
    end
    return files.flatten.compact.uniq
  end    

  def find_translateable_strings_in_file(file)
    regexp = get_translateable_string_regexp
    text = File.read(file)
    return text.scan(regexp)
  end
  
  def get_translateable_string_regexp
    allowed = ' \w0-9%\.,:;@&#<>\/\\\?\!\+\)\(-=\*'
    # looking for 'string' or "string" followed immediately by .t or /
    r1 = Regexp.new('[\'](['+allowed+'\"]*)[\']\.t')
    r2 = Regexp.new('[\"](['+allowed+'\']*)[\"]\.t')
    r3 = Regexp.new('[\'](['+allowed+'\"]*)[\']\s*//')
    r4 = Regexp.new('[\"](['+allowed+'\']*)[\"]\s*//')
    
    return Regexp.union( r1, r2, r3, r4 )
  end
  
end
