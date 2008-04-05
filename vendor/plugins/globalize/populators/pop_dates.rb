ENV["RAILS_ENV"] = 'development'
require 'config/environment'
require 'date'
include Globalize

def save(lang, key, val)
  vt = ViewTranslation.pick(key, lang, 1)
  if vt
    vt.update_attribute(:text, val)
  else
    ViewTranslation.create!(:tr_key => key, :language_id => lang.id, 
      :pluralization_index => 1, :text => val)
  end
end

files = Dir.glob("D:/projects/test/lib/multilingual/locales/lang-data/*.rb")
files.each do |fp|
  sections = fp.split '/'
  fn = sections.last
  code, ext = fn.split '.'

  if %w(ar_IQ zh_CN bn_BD).include?(code)
    lg, ct = code.split '_'
    code = lg
  end

  next if code =~ /_/

  lang = Language.pick(code)
  if !lang
    puts "ERROR: can't find #{code}"
    next
  end

  lang_id = lang.id

  str = File.read(fp)
  eval str

  if lang.code == 'he'
    @lang_data = {
      :days => [ 'יום ראשון', 'יום שני', 'יום שלישי', 'יום רביעי', 'יום חמישי', 'יום ששי', 'יום שבת' ],
      :abdays => [ 'יום א\'', 'יום ב\'', 'יום ג\'', 'יום ד\'', 'יום ה\'', 'יום ו\'', 'שבת' ],
      :months => [ 'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר' ],
      :abmonths => [ 'ינו\'', 'פבר\'', 'מרץ', 'אפר\'', 'מאי', 'יונ\'', 'יול\'', 'אוג\'', 'ספט\'', 'אוק\'', 'נוב\'', 'דצמ\'' ]
    }
  end

  days = @lang_data[:days]
  days.each_index do |idx|
    key = "#{Date::DAYNAMES[idx]} [weekday]"
    val = days[idx]
    save(lang, key, val)
  end


  abdays = @lang_data[:abdays]
  abdays.each_index do |idx|
    key = "#{Date::ABBR_DAYNAMES[idx]} [abbreviated weekday]"
    val = abdays[idx]
    save(lang,key,val)
  end

  months = @lang_data[:months]
  months.each_index do |idx|
    key = "#{Date::MONTHNAMES[idx + 1]} [month]"
    val = months[idx]
    save(lang,key,val)
  end

  abmonths = @lang_data[:abmonths]
  abmonths.each_index do |idx|
    key = "#{Date::ABBR_MONTHNAMES[idx + 1]} [abbreviated month]"
    val = abmonths[idx]
    save(lang,key,val)
  end

  puts "updated #{lang.english_name} [id=#{lang_id}]"
  
end

