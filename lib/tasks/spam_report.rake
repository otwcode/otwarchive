namespace :spam do
  period = 1.day.ago
  desc "Print list of potential spammers"
  task(:print_possible => :environment) do
    new_works = Work.where("created_at > :week and hidden_by_admin = 'false' ", {:week => period})
    pseud_list = new_works.collect { |w|  unless  w.pseuds.first.nil? 
                                                  w.pseuds.first.user_id  
                                          end }.uniq
    pseud_list.each { |pseud|
      new = []
      new_count = 0
      old = 0
      User.find(pseud).works.visible_to_registered_user.each { |w|
        if w.created_at > period
          new << w
          new_count += 1
        else
          old += 1
        end
      }
    user = User.find(pseud)
    if ( new_count-old > 10 )
      puts "#{new_count-old} #{user.login}"
    end
    }
  end
end
