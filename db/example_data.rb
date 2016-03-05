module FixtureReplacement

  #### models
  ## Note1: attributes are what it takes to *create* an object, not what's stored
  ## in the database - this is different from regular fixtures)
  ## Note2: fixtures must be valid to use create_. To test for errors, use new_

#  attributes_for :language do |a|
#    a.short = String.random[1..3]
#    a.name = String.random
#  end

#  attributes_for :locale do |a|
#    a.iso = String.random
#    a.name = String.random
#    a.main = true
#    a.language = create_language
#  end

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
    a.pseud = default_pseud
    a.bookmarkable = default_work
  end

  attributes_for :challenge_assignment do |a|
    a.collection = create_collection
    a.offer_signup = create_challenge_signup(collection: a.collection)
    a.request_signup = create_challenge_signup(collection: a.collection)
  end

  attributes_for :challenge_signup do |a|
    a.pseud = default_pseud
    a.collection = create_collection
  end

  # to create (save) a new chapter you have to have a work first
  # FIXME: authors are only added by default for the first chapter
  # chapter1=new_chapter
  # w=create_work(chapters: [chapter1])
  # chapter2 = create_chapter(work: work, :authors = work.pseuds)
  attributes_for :chapter do |a|
    a.content = random_chapter
    a.published_at = Date.today  
  end
  
  attributes_for :collection do |a|
    pseud = create_pseud
    
    a.collection_participants_attributes = [{pseud: pseud, participant_role: CollectionParticipant::OWNER}]
    a.collection_preference_attributes = {closed: false, moderated: false}
    a.name = String.random
    a.title = random_phrase
  end
  
  attributes_for :collection_item do |a|
    work = create_work
    a.collection = create_collection
    a.item_type = 'Work'
    a.item_id = work.id
  end
  
  attributes_for :collection_preference do |a|
    a.collection = create_collection
  end
  
  attributes_for :collection_profile do |a|
    a.collection = create_collection
  end
  
  attributes_for :collection_participant do |a|
    a.collection = create_collection
    a.pseud = default_pseud
    a.participant_role = CollectionParticipant::NONE
  end

  # note: to get threading, you must use
  # comment = new_comment && comment.set_and_save
  # and it doesn't update the parent, so be sure to re-retrieve it
  # note2: to create an anonymous comment, be sure to set pseud blank
  attributes_for :comment do |a|
    a.content = random_paragraph
    a.pseud = default_pseud
    a.commentable_type = 'Chapter'
    a.commentable_id = create_work.chapters.first.id
  end

  attributes_for :creatorship do |a|
    a.pseud = default_pseud
    a.creation_type = :work
    a.creation = default_work
  end
  
  attributes_for :external_author do |a|
    a.email = random_email
    a.user = default_user
    a.do_not_email = false
  end

  attributes_for :external_author_name do |a|
    a.name = random_phrase
    a.external_author = create_external_author
  end

  attributes_for :external_creatorship do |a|
    a.external_author_name = create_external_author_name
    a.creation_type = :work
    a.creation = default_work
    a.archivist = default_user
  end

  attributes_for :external_work do |a|
    a.url = random_url(random_domain(false),"")
    a.author = random_phrase
    a.title = random_phrase
    a.fandoms = [create_fandom]
  end

  attributes_for :feedback do |a|
    a.summary = random_phrase
    a.comment = random_paragraph
  end
  
  attributes_for :gift_exchange do |a|
    a.signup_open = false
  end
  
  attributes_for :inbox_comment do |a|
    a.user = default_user
    a.feedback_comment = default_comment
  end

  attributes_for :invitation do |a|
    a.invitee_email = random_email
  end

  attributes_for :preference do |a|
  end

  attributes_for :profile do |a|
    a.date_of_birth = DateTime.now.years_ago(rand(30)+14) + rand(12).months
  end
  
  attributes_for :potential_match do |a|
    a.collection = create_collection
    a.request_signup = create_challenge_signup(collection: a.collection)
    a.offer_signup = create_challenge_signup(collection: a.collection)
  end
  
  attributes_for :potential_match_settings do |a|
    a.num_required_prompts = 1
    a.num_required_fandoms = 1
  end
  
  attributes_for :prompt do |a|
    a.collection = create_collection
    a.tag_set = create_tag_set
  end
  
  attributes_for :request do |a|
    a.collection = create_collection
    a.tag_set = create_tag_set
  end
  
  attributes_for :offer do |a|
    a.collection = create_collection
    a.tag_set = create_tag_set
  end  
  
  attributes_for :prompt_restriction do |a|
    a.tag_set = create_tag_set
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
  
  attributes_for :tag_set do |a|
    a.tags = [create_tag(canonical: true)]
  end

  attributes_for :tag do |a|
    a.name = random_tag_name
    a.type = Tag::TYPES[rand(5)+3]
  end

  attributes_for :rating do |a|
    a.name = random_tag_name
    a.adult = false
  end

  attributes_for :warning do |a|
    a.name = random_tag_name
  end

  attributes_for :category do |a|
    a.name = random_tag_name
  end

  attributes_for :media do |a|
    a.name = random_tag_name
  end

  attributes_for :fandom do |a|
    a.name = random_tag_name
  end

  attributes_for :relationship do |a|
    a.name = random_tag_name[0...21] + '/' + random_tag_name[0...20]
  end

  attributes_for :character do |a|
    a.name = random_tag_name
  end

  attributes_for :freeform do |a|
    a.name = random_tag_name
  end

  attributes_for :banned do |a|
    a.name = random_tag_name
  end

  attributes_for :tagging do |a|
    a.tagger = default_tag
    a.taggable = default_work
  end

  attributes_for :common_tagging do |a|
    a.common_id = default_tag.id
    a.filterable = default_work
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

    a.title = random_phrase
    a.authors = [user.default_pseud]
    a.chapters = [new_chapter(authors: [user.default_pseud])]
    a.revised_at = DateTime.now
    a.fandom_string = random_tag_name
    a.warning_string = random_tag_name
    a.rating_string = random_tag_name
  end

  ##### some random generators  
  def random_word
    Faker::Lorem.words(1).to_s
  end

  def random_tag_name(count=42)
    name = random_phrase[1...count].strip
    name = random_tag_name if Tag.find_by_name(name)
    return name
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
    Faker::Internet.user_name + Time.now.sec.to_s + '@' + random_domain(fake)
  end

  def random_url(host=nil,path=nil)
    host = host ? host : 'http://www.' + random_domain
    path = path ? path : random_phrase[1...10].gsub(/ /, '/')
    return host + '/' + path
  end
  
  def random_past_date
    Date.civil((1990...2008).to_a.rand, (1..12).to_a.rand, (1..28).to_a.rand)
  end
  
  def random_past_time
    random_past_date.to_time + (1..1440).to_a.rand.minutes
  end
  
  def random_future_date
    Date.civil(Date.today.year + (1..10).to_a.rand, (1..12).to_a.rand, (1..28).to_a.rand)
  end

end
