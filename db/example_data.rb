module FixtureReplacement

  #### models 
  ## Note1: attributes are what it takes to *create* an object, not what's stored 
  ## in the database - this is different from regular fixtures)
  ## Note2: fixtures must be valid
  
  attributes_for :abuse_report do |a|    
    a.email = random_email
    a.url = random_url(ArchiveConfig.APP_URL)
    a.comment = random_paragraph
  end

  attributes_for :admin do |a|
    password = String.random
    
    a.login = random_phrase("_")[0...40].sub(/_\Z/, "")
    a.email = random_email
    a.password = password
    a.password_confirmation = password
  end
  
  attributes_for :chapter do |a|
    a.content = random_chapter
    a.work = default_work
    a.metadata = default_metadata
    a.posted = 1
  end

  attributes_for :comment do |a|
    a.pseud = default_pseud
    a.content = random_paragraph
    a.name = random_phrase
    a.email = random_email
  end

  attributes_for :creatorship do |a|
    a.pseud = default_pseud
    type = ["work", "chapter"].rand
    if type == "work"
      a.creation_type = "work"
      a.creation = default_work
      
    else type == "chapter"  
      a.creation_type = "chapter"
      a.creation = default_chapter
    end
  end

  attributes_for :metadata do |a|
    a.title = random_phrase
    a.summary = random_paragraph[0...1250]
    a.notes = random_paragraph
  end

  attributes_for :preference do |a|
  end

  attributes_for :profile do |a|
    a.date_of_birth = DateTime.now.years_ago(rand(30)+14) + rand(12).months
  end

  attributes_for :pseud do |a|
    a.user = default_user
    a.name = random_phrase
    a.description = random_phrase
    a.is_default = [0, 1].rand
  end

  attributes_for :reading do |a|
    a.user = default_user
    a.work = default_work
  end

  attributes_for :role do |a|
    a.name = random_phrase[0..40]
  end

  attributes_for :user do |a|
    password = String.random

    a.age_over_13 = "1"
    a.terms_of_service = "1"
    a.login = random_phrase("_")[0...40].sub(/_\Z/, "")
    a.email = random_email
    a.password = password
    a.password_confirmation = password
    a.profile = default_profile
    a.preference = default_preference 
  end

  attributes_for :work do |a|
    a.metadata = default_metadata
    a.expected_number_of_chapters = [rand(30)+1, 1].rand
    a.posted = 1
  end

  ##### some random generators used above
  def random_word(replace=false)
    word = case [:short, :med, :med, :long, :longer, :proper, :compound].rand
      when :short: [['I', 'A', 'O', 'E', 'U'].rand, String.random(rand(2)+2)].rand
      when :med: String.random(rand(2)+4)
      when :long: String.random(rand(3)+6)
      when :longer: String.random(rand(4)+8)
      when :proper: String.random(rand(3)+5).capitalize
      when :compound: String.random(rand(3)+4) + ["'", "-"].rand + String.random(rand(3)+1)
    end
    return word.gsub(/[^\w]/, replace) if replace
    return word
  end
  
  def random_phrase(replace=false)  # 2-4 words
    phrase=random_word.capitalize + ' '
    (1..rand(3)).each {|i| phrase << random_word + " "}
    phrase << random_word
    return phrase.gsub(/[^\w]/, replace) if replace
    return phrase
  end
  
  def random_sentence  # 3-12 words
    sentence = random_word.capitalize + ' '
    (1..rand(10)+1).each {|i| sentence << random_word + ' '}
    sentence << random_word
    sentence << ['.','.','.','.','.','.','?','?','!'].rand
  end
  
  def random_paragraph  # 2-11 sentences
    para = ""
    (1..rand(10)+1).each {|i| para << random_sentence + ' '}
    para << random_sentence
  end

  def random_chapter   # 1-30 paragraphs
    page = ""
    (1..rand(30)+1).each {|i| page << random_paragraph + "\n\n"}
    return page
  end

  def random_domain   # must resolve for email validation
    ['test', 'google', 'amazon', 'yahoo', 'livejournal'].rand + ['.com', '.net', '.org', '.ca'].rand
  end
  
  def random_email()
    random_phrase("_") + '@' + random_domain
  end
  
  def random_url(host=nil,path=nil)
    host = host ? host : 'http://www.' + random_domain
    path = path ? path : random_phrase("/")[0...20]
    return host + '/' + path
  end
  
end