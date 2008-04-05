ENV["RAILS_ENV"] = 'development'
require 'config/environment'

include Globalize

def update_list(list, pl)
  list.each do |lang|
    lm = Language.pick(lang)
    if !lm
      puts "can't find #{lang}"  
      next
    end

    lm.update_attribute(:pluralization, pl)
    puts "updated #{lm.english_name}"
  end
end 

update_list(%w(hu ja ko tr), 'c = 1')
update_list(%w(da nl en de no sv et fi fr el he it pt es eo), 'c == 1 ? 1 : 2')
update_list(%w(ga gd), 'c==1 ? 1 : c==2 ? 2 : 3')
update_list(%w(hr cs ru sk uk), 'c%10==1 && c%100!=11 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3')
update_list(['lv'], 'c%10==1 && c%100!=11 ? 1 : c != 0 ? 2 : 3')
update_list(['lt'], 'c%10==1 && c%100!=11 ? 1 : c%10>=2 && (c%100<10 || c%100>=20) ? 2 : 3')
update_list(['pl'], 'c==1 ? 1 : c%10>=2 && c%10<=4 && (c%100<10 || c%100>=20) ? 2 : 3')
update_list(['sl'], 'c%100==1 ? 1 : c%100==2 ? 2 : c%100==3 || c%100==4 ? 3 : 4')
