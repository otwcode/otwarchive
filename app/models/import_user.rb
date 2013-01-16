#Used with mass importer
class ImportUser < Struct.new(:old_username, :penname,:realname,:joindate,:source_archive_id,:old_user_id,:bio,:password,
                                         :password_salt,:website,:aol,:yahoo,:msn,:icq,:new_user_id,:email,:is_adult)
end