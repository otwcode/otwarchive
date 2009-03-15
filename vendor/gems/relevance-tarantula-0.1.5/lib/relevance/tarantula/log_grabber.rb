class Relevance::Tarantula::LogGrabber
  attr_accessor :path
  def initialize(path)
    @path = path
  end
  
  def clear!
    File.open(@path, "w")
  end
  
  def grab!
    File.read(@path)
  ensure
    clear!
  end
end
