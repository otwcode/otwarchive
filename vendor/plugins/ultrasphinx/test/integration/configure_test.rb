
require "#{File.dirname(__FILE__)}/../test_helper"

class ConfigureTest < Test::Unit::TestCase
  
  CONF = "#{RAILS_ROOT}/config/ultrasphinx/development.conf"
  
  def test_configuration_hasnt_changed  
    unless ENV['DB'] =~ /postgresql/i
      # MySQL only right now... not really a big deal

      File.delete CONF if File.exist? CONF
      Dir.chdir RAILS_ROOT do
        Ultrasphinx::Configure.run
      end
  
      @offset = 4
      @current = open(CONF).readlines[@offset..-1]
      @canonical = open(CONF + ".canonical").readlines[@offset..-1] 
      @canonical.each_with_index do |line, index|
         assert_equal line, @current[index], "line #{index}:#{line.inspect} is incorrect"
      end      
    end
  end

end