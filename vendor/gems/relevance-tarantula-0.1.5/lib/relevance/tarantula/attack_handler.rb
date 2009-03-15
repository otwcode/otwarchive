require 'hpricot'

class Relevance::Tarantula::AttackHandler 
  include ERB::Util
  
  def attacks
    Relevance::Tarantula::AttackFormSubmission.attacks.select(&:output)
  end
  
  def handle(result)
    return unless attacks.size > 0
    regexp = '(' + attacks.map {|a| Regexp.escape a.output}.join('|') + ')'
    response = result.response
    return unless response.html?
    if n = (response.body =~ /#{regexp}/)
      error_result = result.dup
      error_result.success = false
      error_result.description = "XSS error found, match was: #{h($1)}"
      error_result.data = <<-STR
        ########################################################################
        # Text around unescaped string: #{$1}
        ########################################################################
        #{response.body[[0, n - 200].max , 400]}
        
        
        
        
        
        ########################################################################
        # Attack information:
        ########################################################################
        #{attacks.select {|a| a.output == $1}[0].to_yaml}
      STR
      error_result
    end
  end
end
