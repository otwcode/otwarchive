class CollectionObserver < ActiveRecord::Observer
  
  def before_update(new_collection)
    old_collection = Collection.find(new_collection)
    if old_collection && old_collection.unrevealed? && !new_collection.unrevealed? && new_collection.gift_exchange? && new_collection.valid?
      # we have just revealed a gift exchange, notify all recipients
      new_collection.approved_collection_items.each do |collection_item|
        recipient_pseuds = Pseud.parse_bylines(collection_item.recipients, true)[:pseuds]
        recipient_pseuds.each do |pseud|
          unless pseud.user.preference.recipient_emails_off
            UserMailer.deliver_recipient_notification(pseud.user, collection_item.item, new_collection)
          end
        end
      end
    end
  end

end
