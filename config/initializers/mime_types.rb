# for azw3 files
Marcel::MimeType.extend "application/x-mobi8-ebook", extensions: %w[azw3]
Mime::Type.register "application/x-mobi8-ebook", :azw3
# for epub files
Marcel::MimeType.extend "application/epub", extensions: %w[epub]
Mime::Type.register "application/epub", :epub

# for mobi type (already present in marcel types)
Mime::Type.register "application/x-mobipocket-ebook", :mobi
