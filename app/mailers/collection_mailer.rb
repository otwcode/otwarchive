class CollectionMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory
  
  helper :application
  helper :tags
  helper :works
  helper :series

  layout 'mailer'
  default :from => ArchiveConfig.RETURN_ADDRESS
  
  def item_added_notification(work_id, collection_id)
    @creation = Work.find(work_id)
    @collection = Collection.find(collection_id)
    mail(
      :to => @collection.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Work added to " + @collection.title.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end
end