# Model of a blog post, defined in schema.rb
class BlogPost < ActiveRecord::Base
  
  # text for a permalink
  def self.permalink(url)
    t('permalink', :url => url)
  end
  
  # Has a title, author and body
  def written_by
    # Get sting like "Written by Ricky"
    t('byline', :author => self.author)
  end
end