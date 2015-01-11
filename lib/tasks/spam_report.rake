namespace :spam do
  desc "Print list of potential spammers"
  task(:print_possible => :environment) do
    period = 1.day.ago
    history_period = 14.day.ago
    threshold = ArchiveConfig.SPAM_THRESHOLD
    spam_score = Hash.new
    spam_works = Hash.new
    new_works = Work.where("created_at > :week and hidden_by_admin = 'false' ", {:week => period})
    pseud_list = new_works.collect { |w|  unless  w.pseuds.first.nil? 
                                                  w.pseuds.first.user_id  
                                          end }.uniq
    new = []
    pseud_list.each { |pseud|
      new = []
      ips = Hash.new
      old = 0
      begin
        user=User.find(pseud)
      rescue ActiveRecord::RecordNotFound => e
        user = nil
      end
      if  !user.nil? 
        user.works.visible_to_registered_user.each { |w|
          if w.created_at > period
            new << w.id
            ips[w.ip_address] = "true"
          end
          if w.created_at > history_period and  w.created_at <= period
              old += 1
          end
         }
         # Simple scoring function
         # Add the number of ip address used during the period to the number of works posted
         # 
         if ips.length+new.length-old > threshold
           spam_score[pseud] = new.length-old
           spam_works[pseud] = new
         end
       end
    }
    if spam_score.length > 0
      AdminMailer.send_spam_alert(spam_score, spam_works).deliver
    end
  end
end
