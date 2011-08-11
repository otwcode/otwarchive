# encoding: UTF-8

namespace :massimport do

  desc "Import works from intimations.org"
  # one example site
  task(:astolat => :environment) do
    BASEURL = "http://www.intimations.org/fanfic/"
    pseuds = Pseud.parse_bylines("astolat")[:pseuds]
    existing_work_titles = Work.written_by_id(pseuds.map{ |p| p.id }).map{ |w| w.title.downcase }

    puts "Importing Astolat's work from intimations.org..."
    indexparser = StoryParser.new
    index = indexparser.download_text(BASEURL + "index.cgi?sortby=allbydate")
    index = Nokogiri::HTML.parse(index)
    index.css("td.storyentry").each do |storyentry|
      storyentry.inner_html.match /\s*<a class="storytitle" href="(.*?)"><b>(.*?)<\/b>.*?<br>\s*(.*?)<br>\s*(.*?)<br>\s*(.*)/
      url, title, fandom, date, summary = $1, $2, $3, $4, $5
      
      if url.nil?
        puts "Couldn't get URL from entry, skipping:"
        p storyentry.inner_html
        next
      end

      title = title.strip.gsub("<br>", " ").gsub("&amp;", "&")
      
      if existing_work_titles.include? title.downcase
        puts "'#{title}' seems to exist already, skipping."
        next
      end

      puts "Downloading '#{title}' from #{BASEURL + url}..."

      storyparser = StoryParser.new
      options = {
        :do_not_set_current_author => true,
        :pseuds => pseuds,
        :fandom => fandom,
        :post_without_preview => true,
        :encoding => "iso-8859-1"
      }
        
      work = storyparser.download_and_parse_story(BASEURL + url, options)
      work.title = title
      work.revised_at = storyparser.convert_revised_at(date)
      work.summary = storyparser.clean_storytext(summary)
      work.save
      
    end
  end

end
