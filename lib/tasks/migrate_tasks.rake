namespace :After do
# everything commented out has already been run on the archive...
# keeping for historical reference
#   desc "Fix word_count on works and chapters"
#   task(:after_20080922060611_fix_chapter_word_counts => :environment) do
#     ThinkingSphinx.deltas_enabled=false
#     full_sanitizer = HTML::FullSanitizer.new
#     Chapter.all.each {|c| c.update_attribute(:word_count, full_sanitizer.sanitize(c.content).split.length)}
#     Work.all.each {|w| w.update_attribute(:word_count, w.chapters.collect(&:word_count).compact.sum)}
#     ThinkingSphinx.deltas_enabled=true
#   end
#   desc "Strip leading spaces from titles"
#   task(:after_20081002011130_strip_leading_spaces_from_titles => :environment) do
#     Work.find(:all, :conditions => ["INSTR(title, ' ') = 1"]).each do |work|
#       unless work.clean_and_validate_title
#         if work.title.blank?
#           work.title = "Untitled"
#         end
#       end
#       work.save
#     end
#     Chapter.find(:all, :conditions => ["INSTR(title, ' ') = 1"]).each do |chapter|
#       chapter.clean_title
#       chapter.save
#     end
#   end
#   desc "Remove empty Series"
#   task(:after_20081026180141_fix_series_a => :environment) do
#     Series.all.each do |s|
#       if s.works.empty? && s.pseuds.empty?
#         s.destroy
#       end
#     end
#   end
#   desc "Fix Series pseuds"
#   task(:after_20081026180141_fix_series_b => :environment) do
#     Series.all.each do |s|
#       unless s.works.empty?
#         s.works.map(&:pseuds).flatten.each do |p|
#           s.pseuds << p unless s.pseuds.include? p
#         end
#       end
#     end
#   end
#   desc "Update used invitations"
#   task(:after_20081114164535_add_used_to_invitations => :environment) do
#     Invitation.find(:all).each do |invitation|
#       unless invitation.recipient.nil?
#         invitation.update_attribute(:used, true)
#       end
#     end
#   end
#   desc "Change Violence Tag name"
#   task(:after_20090218223404_change_violence_tag_name => :environment) do
#     @old = Tag.find_by_name('Extreme Violence')
#     @new = Tag.find_by_name('Graphic Depictions of Violence')
#     if @old.is_a?(Warning) # @old exists
#       if !@new  # @new doesn't exist yet
#         # give @old the new name
#         @old.update_attribute(:name, 'Graphic Depictions of Violence')
#       else  # @new exists
#         if @new.taggings.count == 0 # but hasn't been used yet
#           @new.destroy # get rid of new, and rename old
#           @old.update_attribute(:name, 'Graphic Depictions of Violence')
#         else # and has been used
#           # change all works that use old to use new instead
#           @old.works.each do |work|
#             work.warnings = work.warnings + [@new] - [@old]
#             work.common_tags = work.common_tags  + [@new] - [@old]
#           end
#           # destroy old
#           if @old.taggings.count == 0
#              @old.destroy
#           else
#              raise "didn't work, please fix database by hand"
#           end
#         end
#       end
#     end
#   end
#   desc "Fix revised_at and published_at dates on works"
#   task(:after_20090307152243_fix_revised_at_dates => :environment) do
#     ThinkingSphinx.deltas_enabled=false
#     Work.find(:all, :conditions => {:published_at => nil}).each do |work|
#       chapter_date = work.chapters.find(:last).created_at
#       work.update_attribute(:published_at, work.created_at)
#       work.update_attribute(:revised_at, chapter_date)
#     end
#     Work.find(:all, :conditions => {:revised_at => nil}).each do |w|
#       w.update_attribute(:revised_at, w.published_at)
#     end
#     ThinkingSphinx.deltas_enabled=true
#   end
#   desc "update all works with default language"
#   task(:after_20090329002541_split_locales_and_languages => :environment) do
#     Work.update_all(["language_id = (?)", Language.default.id]) if Language.default
#   end
#   desc "move bookmarks to pseuds"
#   task(:after_20090318004340_move_bookmarks_to_pseuds => :environment) do
#     if Bookmark.first.respond_to?(:user_id)
#       Bookmark.all.each do |bookmark|
#         if !bookmark.user_id.blank? && bookmark.pseud_id == 0
#           user = User.find(bookmark.user_id)
#           bookmark.update_attribute(:pseud_id, user.default_pseud.id)
#         end
#       end
#     end
#   end
#   desc "update restricted series"
#   task(:after_20090322182529_add_restricted_to_series => :environment) do
#     if Series.first.respond_to?(:restricted)
#       Series.all.each do |series|
#         restr = true
#         series.works.each do |w|
#           restr = restr && w.restricted
#         end
#         series.update_attribute(:restricted, restr)
#       end
#     end
#   end
#   desc "remove invalid inbox comments"
#   task(:revision_1207_clean_up_inbox => :environment) do
#     InboxComment.all.each do |i|
#       if i.feedback_comment.nil? || i.user.nil?
#         i.destroy
#       end
#     end
#   end
#   desc "remove invalid taggings"
#   task(:revision_1223_clean_up_taggings => :environment) do
#     Tagging.all.each do |t|
#       if t.taggable.nil? || t.tagger.nil?
#         t.destroy
#       end
#     end
#   end
#   desc "update sort strings on works - SLOW - prints ids for works which didn't update"
#   task(:after_20090419184639_add_columns_to_work => :environment) do
#     ThinkingSphinx.deltas_enabled=false
#     category = Category.find_by_name("Other")
#     Work.all.each do |work|
#       work.categories=[category] if work.categories.blank?
#       ok1 = work.update_attribute(:title_to_sort_on, work.sorted_title)
#       ok2 = work.update_attribute(:authors_to_sort_on, work.sorted_pseuds)
#       puts "something went wrong with: " + work.id.to_s unless (ok1 && ok2 || !work.published_at)
#       puts "." if work.id.modulo(100) == 0
#     end
#     ThinkingSphinx.deltas_enabled=true
#   end
# desc "add filter taggings - SLOW!"
# task(:after_20090604221238_create_filter_taggings => :environment) do
#   FilterTagging.delete_all
#   FilterTagging.build_from_taggings
# end
# desc "set filter counts - really, REALLY slow"
# task(:after_20090610010041_add_filter_counts => :environment) do
#   FilterCount.set_all
# end
# desc "remove chapters without work ids"
# task(:after_20090613092005_remove_invalid_chapters => :environment) do
#   Chapter.find(:all, :conditions => {:work_id => nil}).each {|c| c.delete}
# end
# desc "change to chapter backdating - slow"
# task(:after_20090613092005_change_backdating => :environment) do
#   ThinkingSphinx.deltas_enabled=false
#   Chapter.find(:all).each do |c|
#     if c.position == 1 && c.work_id && c.work.published_at
#       c.update_attribute(:published_at, c.work.published_at)
#     else
#       c.update_attribute(:published_at, c.created_at)
#     end
#   end
#   ThinkingSphinx.deltas_enabled=true
# end
# desc "give unwrangled fandoms the Uncategorized Fandoms media tag"
# task(:revision_1353_uncategorized_fandoms => :environment) do
#   Tag.update_all(['media_id = ?', Media.uncategorized.id], 'media_id IS NULL')
# end     
end
