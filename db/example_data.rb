module FixtureReplacement

  #### models 
  ## Note1: attributes are what it takes to *create* an object, not what's stored 
  ## in the database - this is different from regular fixtures)
  ## Note2: fixtures must be valid to use _create. To test for errors, use _new
  
  attributes_for :language do |a|
    a.id = 1819
    a.iso_639_1 = 'en'
    a.english_name = 'English'    
  end
  
  attributes_for :country do |a|
    a.id = 223
    a.code = 'US'
    a.english_name = 'United States of America'
  end
  
  attributes_for :abuse_report do |a|    
    a.email = random_email
    a.url = random_url(ArchiveConfig.APP_URL)
    a.comment = random_paragraph
  end

  attributes_for :admin do |a|
    password = random_password
    
    a.login = String.random
    a.email = random_email
    a.password = password
    a.password_confirmation = password
  end

  attributes_for :bookmark do |a|
    a.notes = random_phrase
    a.user = default_user
    a.bookmarkable = default_work
  end
  
  # to create (save) a new chapter you have to have a work first
  # FIXME: authors are only added by default for the first chapter
  # chapter1=new_chapter
  # w=create_work(:chapters => [chapter1]) 
  # chapter2 = create_chapter(:work => work, :authors = work.pseuds)
  attributes_for :chapter do |a|
    a.content = random_chapter
  end

  # note: to get threading, you must use
  # comment = new_comment && comment.set_and_save
  # and it doesn't update the parent, so be sure to re-retrieve it
  # note2: to create a pseud comment, be sure to set email & name blank
  attributes_for :comment do |a|
    a.content = random_paragraph
    a.name = random_phrase
    a.email = random_email
    a.commentable_type = 'Chapter'
    a.commentable_id = create_work.chapters.first.id
  end

  attributes_for :creatorship do |a|
    a.pseud = default_pseud
    a.creation_type = :work
    a.creation = default_work
  end
  
  attributes_for :external_work do |a|
    a.url = random_url(random_domain(false),"")
    a.author = random_phrase
    a.title = random_phrase
  end
  
  attributes_for :feedback do |a|    
    a.comment = random_paragraph
  end
  
  attributes_for :invitation do |a|    
    a.recipient_email = random_email
  end

  attributes_for :preference do |a|
  end

  attributes_for :profile do |a|
    a.date_of_birth = DateTime.now.years_ago(rand(30)+14) + rand(12).months
  end

  attributes_for :pseud do |a|
    a.user = default_user
    a.name = random_phrase[1...40]
    a.description = random_phrase
  end

  attributes_for :reading do |a|
    a.user = default_user
    a.work = default_work
  end

  attributes_for :role do |a|
    a.name = random_phrase[1...40]
  end
  
  attributes_for :series do |a|
    a.title = random_phrase
    a.summary = random_phrase
    a.notes = random_phrase
  end
  
  attributes_for :serial_work do |a|
    a.series = create_series
    a.pseud = create_pseud
    a.position = 1
  end
 
  attributes_for :tag do |a|
    a.tag_category = TagCategory::DEFAULT
    a.name = random_phrase[1...42]
  end
  
  attributes_for :tagging do |a|
    a.tag = default_tag
    a.taggable = default_work
  end

  attributes_for :tag_category do |a|
    a.name = random_phrase
  end
  
  attributes_for :tag_relationship do |a|
    a.name = random_word
    a.verb_phrase = random_phrase.downcase
    a.distance = rand(4)
  end

  attributes_for :user do |a|
    password = random_password

    a.age_over_13 = "1"
    a.terms_of_service = "1"
    a.login = String.random
    a.email = random_email
    a.password = password
    a.password_confirmation = password
  end

  attributes_for :work do |a|
    user = create_user
    fandom_tag = create_tag(:tag_category => TagCategory::FANDOM)
    rating_tag = Tag::DEFAULT_RATING_TAG
    warning_tag = Tag::DEFAULT_WARNING_TAG    

    a.title = random_phrase
    a.authors = [user.default_pseud]
    a.chapters = [new_chapter(:authors => [user.default_pseud])]
    a.tags = [fandom_tag, rating_tag, warning_tag]
    a.published_at = DateTime.now
    a.revised_at = DateTime.now
  end

  ##### some random generators
  def random_word
    Faker::Lorem.words(1).to_s
  end
 
  def random_phrase(count=nil)  # 2-4 words
    count = count ? count : rand(3)+2
    phrase=random_word.capitalize + ' '
    (1..rand(3)).each {|i| phrase << random_word + " "}
    phrase << random_word
  end
  
  def random_sentence(count=nil)  # 3-12 words
    count = count ? count : rand(10)+3
    Faker::Lorem.sentence(count)
  end
  
  def random_paragraph(count=nil)  # 2-10 sentences
    count = count ? count : rand(9)+2
    Faker::Lorem.paragraph(count)
  end

  def random_chapter(count=nil)   # 1-20 paragraphs
    count = count ? count : rand(20)
    chapter = ""
    (1...rand(count)).each {|i| chapter << random_paragraph + "\n\n"}
    chapter << random_paragraph
  end

  def random_domain(fake=true)   # fake domains may not resolve in dns
    return Faker::Internet.domain_name if fake
    ['aol.com', 'gmail.com', 'hotmail.com', 'mac.com', 'msn.com', 'rogers.com', 'sympatico.ca', 'yahoo.com'].rand  # domains listed in the plugin as known
  end

  def random_password   # strong?
    random_word + Faker::Address.zip_code + random_word.capitalize
  end
  
  def random_email(fake=false)
    Faker::Internet.user_name + '@' + random_domain(fake)
  end
  
  def random_url(host=nil,path=nil)
    host = host ? host : 'http://www.' + random_domain
    path = path ? path : random_phrase[1...10].gsub(/ /, '/')
    return host + '/' + path
  end
  
end
