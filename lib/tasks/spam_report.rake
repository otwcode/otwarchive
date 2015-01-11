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
      score = 0
      begin
        user=User.find(pseud)
      rescue ActiveRecord::RecordNotFound => e
        user = nil
      end
      if  !user.nil? 
        user.works.visible_to_registered_user.each { |work|
          if work.akismet_score.nil? #&& Rails.env.production?
            content = work.chapters_in_order.map{ |c| c.content }.join
            work.akismet_score = Akismetor.spam?(
              :comment_type => 'Fan Fiction',
              :key => ArchiveConfig.AKISMET_KEY,
              :blog => ArchiveConfig.AKISMET_NAME,
              :user_ip => work.ip_address,
              :comment_date_gmt => work.created_at.to_time.iso8601,
              :blog_lang => work.language.short,
              :comment_author => user.login,
              :comment_author_email => user.email,
              :comment_content => content
            )
            unless work.akismet_score.nil?
              work.save 
            end
          end
          if work.created_at > period
            new << work.id
            ips[work.ip_address] = "true"
            if work.akismet_score = false
              score = score + 1
            else
              score = score + 4
            end
          end
          if work.created_at > history_period and  work.created_at <= period
            if work.akismet_score = false
              score = score -2
            end
          end
         }
         puts score
         if ips.length+score > threshold
           spam_score[pseud] = ips.length+score
           spam_works[pseud] = new
         end
       end
    }
    if spam_score.length > 0
      AdminMailer.send_spam_alert(spam_score, spam_works).deliver
    end
  end
end
