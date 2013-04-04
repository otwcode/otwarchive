#  https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/4_YvCpLzL58

module JSON 
  class << self 
    alias :old_parse :parse 
    def parse(json, args = {}) 
      args[:create_additions] = false 
      old_parse(json, args) 
    end 
  end 
end