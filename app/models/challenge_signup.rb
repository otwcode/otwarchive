class ChallengeSignup < ActiveRecord::Base
  # -1 represents all matching
  ALL = -1
  
  belongs_to :pseud
  belongs_to :collection

  has_many :prompts, :dependent => :destroy
  has_many :requests, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  
  has_many :offer_potential_matches, :class_name => "PotentialMatch", :foreign_key => 'offer_signup_id', :dependent => :destroy
  has_many :request_potential_matches, :class_name => "PotentialMatch", :foreign_key => 'request_signup_id', :dependent => :destroy

  has_many :offer_assignments, :class_name => "ChallengeAssignment", :foreign_key => 'offer_signup_id'
  has_many :request_assignments, :class_name => "ChallengeAssignment", :foreign_key => 'request_signup_id'


  # we reject prompts if they are empty except for associated references
  accepts_nested_attributes_for :offers, :prompts, :requests, {:allow_destroy => true, 
    :reject_if => proc { |attrs| 
                          attrs[:url].blank? && attrs[:description].blank? && 
                          (attrs[:tag_set_attributes].nil? || attrs[:tag_set_attributes].all? {|k,v| v.blank?}) &&
                          (attrs[:optional_tag_set_attributes].nil? || attrs[:optional_tag_set_attributes].all? {|k,v| v.blank?})                          
                        }
  }

  named_scope :by_user, lambda {|user|
    {
      :select => "DISTINCT challenge_signups.*",
      :joins => "INNER JOIN pseuds ON challenge_signups.pseud_id = pseuds.id
                        INNER JOIN users ON pseuds.user_id = users.id",
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :by_pseud, lambda {|pseud|
    {
      :conditions => ['pseud_id = ?', pseud.id]
    }
  }
      

  named_scope :in_collection, lambda {|collection| {:conditions => ['collection_id = ?', collection.id] }}

  ### VALIDATION
  # we validate number of prompts/requests/offers at the challenge
  validate :number_of_prompts
  def number_of_prompts
    if (challenge = collection.challenge)
      errors_to_add = []
      %w(offers requests).each do |prompt_type|
        allowed = self.send("#{prompt_type}_num_allowed")
        required = self.send("#{prompt_type}_num_required")
        count = eval("@#{prompt_type}") ? eval("@#{prompt_type}.size") : eval("#{prompt_type}.size")
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

  # define "offers_num_allowed" etc here 
  %w(offers requests).each do |prompt_type|
    %w(required allowed).each do |permission|
      define_method("#{prompt_type}_num_#{permission}") do
        collection.challenge.respond_to?("#{prompt_type}_num_#{permission}") ? collection.challenge.send("#{prompt_type}_num_#{permission}") : 0
      end
    end
  end
  
  # sort alphabetically
  include Comparable
  def <=>(other)
    self.pseud.name.downcase <=> other.pseud.name.downcase
  end

  def user
    self.pseud.user
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
  
  def get_match_settings
    if collection && collection.challenge
      collection.challenge.potential_match_settings
    else
      nil
    end
  end
  
  def byline
    pseud.byline
  end

  # Returns nil if not a match otherwise returns PotentialMatch object
  # self is the request, other is the offer
  def match(other)
    settings = get_match_settings
    return nil unless settings
    potential_match_attributes = {:offer_signup => other, :request_signup => self, :collection => self.collection}
    prompt_matches = []
    self.requests.each do |request|
      other.offers.each do |offer|
        if (match = request.match(offer))
          prompt_matches << match
        end
      end
    end
    return nil if settings.num_required_prompts == ALL && prompt_matches.size != self.requests.size
    if prompt_matches.size >= settings.num_required_prompts
      # we have a match
      potential_match_attributes[:num_prompts_matched] = prompt_matches.size
      potential_match = PotentialMatch.new(potential_match_attributes)
      potential_match.potential_prompt_matches = prompt_matches
      potential_match
    else
      nil
    end
  end
  
end
