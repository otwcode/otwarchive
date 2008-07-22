class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true
  
  # Add multiple pseuds as authors to a creation
  def self.add_authors(creation, pseuds)
    pseuds.each { |p| p.add_creations([creation]) } if pseuds
  end 
  
  # Change authorship of work(s) from a particular pseud to the orphan account
  # Include appropriate chapters and comments (not all comments, just comments left on the work that would identify the author)
  def self.orphan(pseuds, works)
    for pseud in pseuds
      for work in works
        unless pseud.blank? || work.blank?
          creatorship = work.creatorships.find(:first, :conditions => {:pseud_id => pseud.id})
          orphan_pseud = User.orphan_account.default_pseud
          creatorship.pseud_id = orphan_pseud.id
          creatorship.save
          chapter_ids = work.chapters.collect(&:id).join(",")
          comment_ids = work.find_all_comments.collect(&:id).join(",")
          series_ids = work.series.collect(&:id).join(",")
          Creatorship.update_all("pseud_id = #{orphan_pseud.id}", 
                                 "pseud_id = '#{pseud.id}' AND creation_type = 'Chapter' AND creation_id IN (#{chapter_ids})") unless chapter_ids.blank?
          Comment.update_all("pseud_id = #{orphan_pseud.id}", "pseud_id = '#{pseud.id}' AND id IN (#{comment_ids})") unless comment_ids.blank?
          Creatorship.update_all("pseud_id = #{orphan_pseud.id}", 
                                 "pseud_id = '#{pseud.id}' AND creation_type = 'Series' AND creation_id IN (#{series_ids})") unless series_ids.blank? 
        end   
      end
    end    
  end
  
end
