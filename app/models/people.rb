class People
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
    Pseud.find(:all, :conditions => ["name LIKE ?", escaped + '%' ], :order => "name")
  end

  def authors
    pseuds.select {|a| a.visible_works_count > 0}
  end

  def reccers
    pseuds.select {|a| a.visible_recs_count > 0}
  end

end
