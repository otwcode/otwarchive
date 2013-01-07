namespace :deploy do

  desc "Get servername"
  task(:get_servername) do
    @server ||= %x{hostname -s}.chomp
  end

  desc "clear subscriptions on stage"
  task(:clear_subscriptions => [:get_servername, :environment]) do
    if @server == "stage"
      Subscription.delete_all
    else
      puts "Don't clear subscriptions except on stage!!!"
    end 
  end
  
  desc "clear email addresses on stage"
  task(:clear_emails => [:get_servername, :environment]) do
    if @server == "stage" || @server == "dev"     
      puts "redacting all email addresses, will take a while"
      User.where("login NOT IN (?)", ArchiveConfig.DUMP_EMAIL).find_each {|u| u.update_attribute(:email, "#{u.login}-test@ao3.org")}
    else
      puts "Don't clear emails except on stage!!!"
    end
  end

end
