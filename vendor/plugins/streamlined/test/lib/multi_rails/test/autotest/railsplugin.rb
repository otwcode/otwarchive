# Discover our lib and tests for autotest'ing Rails Plugins
class Autotest::Railsplugin < Autotest
  def initialize
    super
    @exceptions = /\/\./
    @test_mappings = {
      /^lib\/(.*)\.rb$/ => proc { |filename, m|
        # p "match #{m[1]}"
        file = File.basename(filename).gsub("_", "_?").gsub(".rb", "")
        foo = files_matching %r%^test/.*#{file}_test.rb$%
        # p "the file: #{file}"
        # p "the regex: #{files_matching %r%^test/.*#{file}_test.rb$%}"
        # p "files_matching: #{foo}"
        foo
      },
      /^test\/.*_test\.rb$/ => proc { |filename, _|
        filename
      }
    }
  end
  
  def files_matching regexp
    # puts @files.sort.inspect
    @files.keys.select { |k|
      k =~ regexp
    }
  end
  
  # def files_matching regexp
  #   @files.keys.select { |k|
  #     k =~ regexp
  #   }
  # end
  
end