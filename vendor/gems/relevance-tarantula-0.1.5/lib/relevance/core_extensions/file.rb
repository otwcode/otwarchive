module Relevance::CoreExtensions::File 
  def extension(path)
    extname(path)[1..-1]
  end
end

class File
  extend Relevance::CoreExtensions::File
end