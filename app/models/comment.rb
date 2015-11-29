class Comment < ActiveRecord::Base

  include HtmlCleaner

  attr_protected :content_sanitizer_version, :unreviewed

  belongs_to :pseud
  belongs_to :commentable, :polymorphic => true
  belongs_to :parent, :polymorphic => true

  has_many :inbox_comments, :foreign_key => 'feedback_comment_id', :dependent => :destroy
  has_many :users, :through => :inbox_comments

  validates_presence_of :name, :unless => :pseud_id
  validates :email, :email_veracity => {:on => :create, :unless => :pseud_id}

  validates_presence_of :content
  validates_length_of :content,
    :maximum => ArchiveConfig.COMMENT_MAX,
    :too_long => ts("must be less than %{count} characters long.", :count => ArchiveConfig.COMMENT_MAX)

  validate :check_for_spam
  def check_for_spam
    errors.add(:base, ts("This comment looks like spam to our system, sorry! Please try again, or create an account to comment.")) unless check_for_spam?
  end
  
  validates :content, :uniqueness => {:scope => [:commentable_id, :commentable_type, :name, :email, :pseud_id], :message => ts("^This comment has already been left on this work. (It may not appear right away for performance reasons.)")}

  scope :recent, lambda { |*args| {:conditions => ["created_at > ?", (args.first || 1.week.ago.to_date)]} }
  scope :limited, lambda {|limit| {:limit => limit.kind_of?(Fixnum) ? limit : 5} }
  scope :ordered_by_date, :order => "created_at DESC"
  scope :top_level, :conditions => ["commentable_type in (?)", ["Chapter", "Bookmark"]]
  scope :include_pseud, :include => :pseud
  scope :not_deleted, :conditions => {:is_deleted => false}
  scope :reviewed, conditions: {unreviewed: false}
  scope :unreviewed_only, conditions: {unreviewed: true}

  # Gets methods and associations from acts_as_commentable plugin
  acts_as_commentable
  has_comment_methods

  def akismet_attributes
    {
      :key => ArchiveConfig.AKISMET_KEY,
      :blog => ArchiveConfig.AKISMET_NAME,
      :user_ip => ip_address,
      :user_agent => user_agent,
      :comment_author => name,
      :comment_author_email => email,
      :comment_content => content
    }
  end

  before_create :set_depth
  before_create :set_thread_for_replies
  before_create :set_parent_and_unreviewed
  after_create :update_thread
  before_create :adjust_threading, :if => :reply_comment?

  # Set the depth of the comment: 0 for a first-class comment, increasing with each level of nesting
  def set_depth
    self.depth = self.reply_comment? ? self.commentable.depth + 1 : 0
  end

  # The thread value for a reply comment should be the same as its parent comment
  def set_thread_for_replies
    self.thread = self.commentable.thread if self.reply_comment?
  end

  # Save the ultimate parent and reviewed status
  def set_parent_and_unreviewed
    self.parent = self.reply_comment? ? self.commentable.parent : self.commentable
    # we only mark comments as unreviewed if moderated commenting is enabled on their parent
    self.unreviewed = self.parent.respond_to?(:moderated_commenting_enabled?) && 
                      self.parent.moderated_commenting_enabled? && 
                      !User.current_user.try(:is_author_of?, self.ultimate_parent)
    return true # because if reviewed is the return value, when it's false the record won't save!
  end
  
  # is this a comment by the creator of the ultimate parent
  def is_creator_comment?
    pseud && pseud.user && pseud.user.try(:is_author_of?, ultimate_parent)
  end
  
  def moderated_commenting_enabled?
    parent.respond_to?(:moderated_commenting_enabled?) && parent.moderated_commenting_enabled?
  end

  # We need a unique thread id for replies, so we'll make use of the fact
  # that ids are unique
  def update_thread
    self.update_attribute(:thread, self.id) unless self.thread
  end

  def adjust_threading
    self.commentable.add_child(self)
  end

  # Is this a first-class comment?
  def top_level?
    !self.reply_comment?
  end

  def comment_owner
    self.pseud.try(:user)
  end

  def comment_owner_name
    self.pseud.try(:name) || self.name
  end

  def comment_owner_email
    comment_owner.try(:email) || self.email
  end

  # override this method from commentable_entity.rb
  # to return the name of the ultimate parent this is on
  # we have to do this somewhat roundabout because until the comment is
  # set and saved, the ultimate_parent method will not work (the thread is not set)
  # and this is being called from before then.
  def commentable_name
    self.reply_comment? ? self.commentable.ultimate_parent.commentable_name : self.commentable.commentable_name
  end

  # override this method from comment_methods.rb to return ultimate
  alias :original_ultimate_parent :ultimate_parent
  def ultimate_parent
    myparent = self.original_ultimate_parent
    myparent.kind_of?(Chapter) ? myparent.work : myparent
  end

  def self.commentable_object(commentable)
    commentable.kind_of?(Work) ? commentable.last_posted_chapter : commentable
  end

  def find_all_comments
    self.all_children
  end

  def count_all_comments
    self.children_count
  end

  def count_visible_comments
    self.children_count #FIXME
  end

  def check_for_spam?
    #don't check for spam while running tests or if the comment is 'signed'
    self.approved = Rails.env.test? || !self.pseud_id.nil? || !Akismetor.spam?(akismet_attributes)
  end

  def mark_as_spam!
    update_attribute(:approved, false)
    # don't submit spam reports unless in production mode
    Rails.env.production? && Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    update_attribute(:approved, true)
    # don't submit ham reports unless in production mode
    Rails.env.production? && Akismetor.submit_ham(akismet_attributes)
  end

  def sanitized_content
    sanitize_field self, :content
  end
end
