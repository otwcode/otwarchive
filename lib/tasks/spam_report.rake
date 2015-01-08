namespace :spam do
  desc "Print list of potential spammers"
  task(:print_possible => :environment) do
    new_works=Work.where("created_at > :week and hidden_by_admin = 'false' ", {:week => 1.week.ago})
    ps=new_works.collect { |w|  w.pseuds.first.user_id  }.uniq
    puts ps
  end
end
