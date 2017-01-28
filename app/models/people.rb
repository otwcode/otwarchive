class People
  include ActiveModel::ForbiddenAttributesProtection
  attr_reader :char

  def self.all
    (('0'..'9').to_a + ('A'..'Z').to_a + ['_']).map { |c| new(c) }
  end

  def self.find(param)
    all.detect { |c| c.to_param == param } || raise(ActiveRecord::RecordNotFound)
  end

  def initialize(char)
    @char = char
  end

  def to_param
    @char.downcase
  end

  def escaped
    if @char == "_"
      return "\\_" 
    else
      return @char
    end
  end

  def pseuds
    Pseud.find(:all, :include => :user, :conditions => ["name LIKE ?", escaped + '%' ], :order => "name")
  end

  def authors
    if User.current_user.nil?
      Pseud.with_public_works.find(:all, :include => :user, :conditions => ["name LIKE ?", escaped + '%' ], :order => "name")    
    else
      Pseud.with_posted_works.find(:all, :include => :user, :conditions => ["name LIKE ?", escaped + '%' ], :order => "name")
    end
  end

  def reccers
    Pseud.with_public_recs.find(:all, :include => :user, :conditions => ["name LIKE ?", escaped + '%' ], :order => "name")
  end

end
