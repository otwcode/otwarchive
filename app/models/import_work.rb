#Object for use during mass imports
class ImportWork <  Struct.new(:old_work_id,:new_work_id,:author_string,:title,:summary,:classes,:old_user_id,:characters,
             :hits,:new_pseud_id,:new_user_id,:word_count,:completed,:updated,:source_archive_id,:generes,:rating,
             :rating_integer,:warnings,:chapters,:published,:cats)
end