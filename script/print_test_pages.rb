#!/usr/bin/env ruby
# 
# generate static copies of all the listed pages for more effective browsercam testing
#

require 'open-uri'
require 'optparse'

DEFAULT_SITE = 'http://' + `whoami`.chomp + '.archiveofourown.org'
DEFAULT_DIR = Dir.pwd + '/public/pagetesting/'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Creates static copies of various pages for speedier CSS testing.\n"
  opts.banner += "Usage: print_test_pages.rb [options] [path1 path2 ...]"
  options[:redo] = false
  opts.on('-r', '--redo', 'Redo all pages (otherwise will only recreate index and add any pages that were not successfully made on last run)') do
    options[:redo] = true
  end
  
  options[:site] = DEFAULT_SITE
  opts.on('-s', "--site [site]", "Specify home site [#{DEFAULT_SITE}]") do |site|
    options[:site] = site
  end
  
  options[:dir] = DEFAULT_DIR
  opts.on('-d', "--dir [dir]", "Specify directory for output files [#{DEFAULT_DIR}]") do |dir|
    options[:dir] = dir
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!
  

# all the paths we want to visit unless specified on commandline
# these are all the archive pages that can be visited without being logged in
DEFAULT_PAGE_PATHS = %w(
  /archive_faqs
  /archive_faqs/1
  /bookmarks
  /bookmarks/search
  /chapters/15?view_adult=true
  /chapters/15/comments?view_adult=true
  /chapters/15/comments/7759?view_adult=true
  /chapters/15/comments/new?view_adult=true
  /collections
  /collections/list_challenges
  /collections/yuletide
  /collections/yuletide/bookmarks
  /collections/yuletide/collections
  /collections/yuletide/collections/yuletide2010
  /collections/yuletide/fandoms
  /collections/yuletide/fandoms/Supernatural
  /collections/yuletide/media
  /collections/yuletide/media/Movies
  /collections/yuletide/people
  /collections/yuletide/people/0
  /collections/yuletide/tags
  /collections/yuletide/tags/12th%20Century%20CE%20RPF/works
  /collections/yuletide/tags/12th%20Century%20CE%20RPF
  /collections/yuletide/works
  /collections/yuletide/works/141897
  /comments
  /comments/7759
  /comments/7759/comments
  /external_works
  /external_works/19?view_adult=true
  /external_works/19/bookmarks
  /fandoms
  /fandoms/Supernatural
  /invite_requests
  /known_issues
  /known_issues/1
  /languages
  /media
  /media/Movies
  /orphans
  /orphans/about
  /people
  /people/0
  /search
  /series
  /series/26
  /series/7434/bookmarks
  /skins
  /skins/1
  /static/collections/yuletide
  /static/collections/yuletide/fandoms
  /static/collections/yuletide/fandoms/Supernatural
  /support
  /tags
  /tags/Movies
  /tags/Movies/works
  /tags/search
  /user_sessions/new
  /users
  /users/astolat
  /users/astolat/bookmarks
  /users/astolat/collection_items
  /users/astolat/collections
  /users/astolat/gifts
  /users/astolat/profile
  /users/astolat/pseuds
  /users/astolat/pseuds/astolat
  /users/astolat/pseuds/astolat/bookmarks
  /users/astolat/pseuds/astolat/series
  /users/astolat/pseuds/astolat/works
  /users/astolat/series
  /series/6845?view_adult=true
  /users/astolat/works
  /users/astolat/works/169345?view_adult=true
  /users/astolat/works/drafts
  /users/astolat/works/new
  /users/astolat/works/show_multiple
  /works
  /works/15?view_adult=true
  /works/15/bookmarks?view_adult=true
  /works/15/chapters?view_adult=true
  /works/search
)


@page_paths = ARGV.empty? ? DEFAULT_PAGE_PATHS : ARGV

if options[:redo]
  @page_paths.each do |page_path|
    filename = page_path.gsub(/[^0-9a-zA-Z]/, '_').gsub(/^_/, '') + '.html'
    File.delete(options[:dir] + filename)
  end
end

index_content = ""

@page_paths.each do |page_path|
  filename = page_path.gsub(/[^0-9a-zA-Z]/, '_').gsub(/^_/, '') + '.html'
  index_content += "<li><a href=\"#{filename}\">#{filename}</a></li>\n"
  if !FileTest.exists?(options[:dir] + filename)
    url = options[:site] + page_path
    puts "Saving #{url}"
    webpage = open(url)
    content = webpage.read

    File.open(options[:dir] + filename, "w") do |f|
      f.write content
    end  
  end
end

File.open(options[:dir] + 'index.html', "w") do |f|
  f.write "<html><body><ul>\n" + index_content + "\n</ul></body></html>"
end

puts "Done!"