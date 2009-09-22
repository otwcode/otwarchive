class ExternalAuthor < ActiveRecord::Base

  EMAIL_LENGTH_MIN = 3
  EMAIL_LENGTH_MAX = 300

  belongs_to :user
  has_many :external_creatorships
  has_many :works, :through => :external_creatorships, :source => :creation, :source_type => 'Work', :uniq => true  
  
  has_many :external_author_names, :dependent => :destroy
  accepts_nested_attributes_for :external_author_names, :allow_destroy => true
  validates_associated :external_author_names


  validates_presence_of :email, :message => t('email_blank', :default => 'Please enter an email address')

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true,    
    :message => t('email_in_use', :default => 'Sorry, that email address is already being used.')
     
  validates_length_of :email, :within => EMAIL_LENGTH_MIN..EMAIL_LENGTH_MAX, 
    :too_short => t('email_too_short', :default => "Your email address is too short (minimum is #{EMAIL_LENGTH_MIN} characters)"),
    :too_long => t('email_too_long', :default => "Your email address is too long (maximum is #{EMAIL_LENGTH_MAX} characters)")

  validates_email_veracity_of :email, 
      :message => t('email_invalid', :default => 'This does not seem to be a valid email address.')

  
  def claimed?
    is_claimed
  end
  
  def claim!(user)
    raise Error(t('no_claiming_user', :default => "There is no user claiming this external author.")) unless user 
    raise Error(t('already_claimed', :default => "This external author is already claimed")) if claimed?
    
    self.user = user
    self.external_creatorships.select {|ec| ec.creation_type == "Work"}.each do |external_creatorship|
      # remove archivist as owner, add user as owner
      archivist = external_creatorship.archivist
      work = external_creatorship.creation
      pseuds_to_remove = work.pseuds.select {|pseud| archivist.pseuds.include?(pseud)}
      pseud_to_add = self.user.default_pseud
      
      pseuds_to_remove.each do |pseud_to_remove|
        pseud_to_remove.change_ownership(work, pseud_to_add)
      end
      work.save!
    end
    
    self.is_claimed = true
    save!
  end
  
  def unclaim!
    return false unless self.is_claimed
    
    self.external_creatorships.select {|ec| ec.creation_type == "Work"}.each do |external_creatorship|
      # remove user, add archivist back
      archivist = external_creatorship.archivist
      work = external_creatorship.creation

      pseuds_to_remove = work.pseuds.select {|pseud| self.user.pseuds.include?(pseud)}
      pseud_to_add = archivist.default_pseud
      
      pseuds_to_remove.each do |pseud_to_remove|
        pseud_to_remove.change_ownership(work, pseud_to_add)
      end
      work.save!
    end
    
    self.user = nil
    self.is_claimed = false
    save!
  end
  
end
