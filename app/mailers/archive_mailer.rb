class ArchiveMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory
  
  layout 'mailer'
  helper :mailer
  default from: "Archive of Our Own " + "<#{ArchiveConfig.RETURN_ADDRESS}>"

end