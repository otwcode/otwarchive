ActiveRecord::Schema.define do

  create_table "blog_posts", :force => true do |t|
    t.column "title",:string
    t.column "body", :text
    t.column "author", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    
  end
end
