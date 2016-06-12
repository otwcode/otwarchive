namespace :db_clean do

  desc "reset whether a work is anonymous  or unrevealed"
  task(:work_collections => :environment) do

  def check_work(w,collections)
    unrevealed = false
    anonymous = false
    change = false
    collections.each do |c|
      unrevealed = true if c.unrevealed?
      anonymous = true if c.anonymous?
    end
   if w.in_anon_collection !=  anonymous then
     w.in_anon_collection = anonymous
     change = true
   end
   if w.in_unrevealed_collection != unrevealed then
     w.in_unrevealed_collection = unrevealed
     change = true
   end
   w.save if change == true
  end

    Work.find_each do |w| 
      collections = w.collections
      check_work(w,collections)  unless collections.blank? 
    end
  end

end
