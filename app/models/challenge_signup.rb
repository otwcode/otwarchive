class ChallengeSignup < ActiveRecord::Base
  belongs_to :pseud
  has_one :user, :through => :pseud
  belongs_to :collection
  #has_many :challenge_assignments, :dependent => :destroy

  has_many :prompts, :dependent => :destroy
  has_many :requests, :class_name => "Prompt", :conditions => {:offer => false}
  has_many :offers, :class_name => "Prompt", :conditions => {:offer => true}
  
  # we reject prompts if they are empty except for associated references
  accepts_nested_attributes_for :offers, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? || k.match(/collection/) } }
  accepts_nested_attributes_for :requests, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? || k.match(/collection/) } }

  named_scope :by_user, lambda {|user|
    {
      :select => "DISTINCT challenge_signups.*",
      :joins => "INNER JOIN pseuds ON challenge_signups.pseud_id = pseuds.id
                        INNER JOIN users ON pseuds.user_id = users.id",
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :in_collection, lambda {|collection| {:conditions => ['collection_id = ?', collection.id] }}

  ### VALIDATION
  # we validate number of prompts/requests/offers at the challenge
  validate :number_of_prompts
  def number_of_prompts
    if (challenge = collection.challenge)
      errors_to_add = []
      %w(prompts offers requests).each do |prompt_type|
        allowed = challenge.respond_to?("#{prompt_type}_num_allowed") ? 
          challenge.send("#{prompt_type}_num_allowed") : 
          ArchiveConfig.PROMPTS_MAX
        required = challenge.respond_to?("#{prompt_type}_num_required") ? 
          challenge.send("#{prompt_type}_num_required") :
          0
        count = eval("self.#{prompt_type}.length") || 0
        unless count.between?(required, allowed)
          if allowed == 0
            errors_to_add << t("challenge_signup.#{prompt_type}_not_allowed", 
              :default => "You cannot submit any #{prompt_type.pluralize} for this challenge.")
          elsif required == allowed
            errors_to_add << t("challenge_signup.#{prompt_type}_mismatch", 
              :default => "You must submit exactly {{required}} #{required > 1 ? prompt_type.pluralize : prompt_type} for this challenge. You currently have {{count}}.", 
              :required => required, :count => count)
          else
            errors_to_add << t("challenge_signup.#{prompt_type}_range_mismatch", 
              :default => "You must submit between {{required}} and {{allowed}} #{prompt_type.pluralize} to sign up for this challenge. You currently have {{count}}.",
              :required => required, :allowed => allowed, :count => count)
          end
        end
      end
      unless errors_to_add.empty?
        # yuuuuuck :( but so much less ugly than define-method'ing these all
        self.errors.add_to_base(errors_to_add.join("</li><li>"))
      end
    end
  end


  def user_allowed_to_destroy?(current_user) 
    (self.pseud.user == current_user) || self.collection.user_is_maintainer?(current_user)
  end
  
  def user_allowed_to_see?(current_user)
    (self.pseud.user == current_user) || user_allowed_to_see_signups?(current_user)
  end
  
  def user_allowed_to_see_signups?(user)
    self.collection.user_is_maintainer?(user) || 
      (self.challenge.respond_to?("user_allowed_to_see_signups?") && self.challenge.user_allowed_to_see_signups?(user))
  end
    
end
