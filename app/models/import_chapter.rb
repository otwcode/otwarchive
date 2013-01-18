#Mass Importer Object
class ImportChapter < Struct.new(:new_chapter_id,:new_work_id,:old_story_id,:source_archive_id,:title,:pseud_id,
                             :summary,:notes,:old_user_id,:body,:position,:date_posted)
end