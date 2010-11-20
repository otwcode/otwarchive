# https://github.com/thoughtbot/paperclip/issuesearch?state=open&q=fingerprint#issue/346
if defined? ActionDispatch::Http::UploadedFile
  ActionDispatch::Http::UploadedFile.send(:include, Paperclip::Upfile)
end
