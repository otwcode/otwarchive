# TODO - autotest blows up right now, needs work
class Autotest::Streamlined < Autotest
  def initialize
    super
    @exceptions = /\/\./
    @test_mappings = {
      /^lib\/(.*)\.rb$/ => proc { |filename, m|
        file = File.basename(filename).gsub("_", "_?").gsub(".rb", "")
        files = files_matching %r%^test/.*#{file}_test.rb$%
      },
      /^test\/.*_test\.rb$/ => proc { |filename, _|
        filename
      }
    }
  end
  
  def files_matching regexp
    @files.keys.select { |k|
      k =~ regexp
    }
  end
end