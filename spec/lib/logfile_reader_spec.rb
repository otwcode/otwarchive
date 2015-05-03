# -*- coding: utf-8 -*-
require 'spec_helper'

describe LogfileReader do
  include UsesTempFiles
  include LogfileReader

  context "with some logfiles" do
    LogfileReader::LOGFILE_DIR = "usr/local/nginx/logs/"
    in_directory_with_files(LogfileReader::LOGFILE_DIR, %w(default.log.1 default.log.2))

    before do
      # randomly grabbed content out of logfiles with IP addresses changed for privacy
      logfile_content_feb_14 = '
      40.50.60.70 - - [14/Feb/2012:00:54:06 +0000] "GET /works/329717/navigate?view_adult=true HTTP/1.0" 302 161 "-" "FLAG/2.1 (Webservice)"
      40.50.60.70 - - [14/Feb/2012:00:54:06 +0000] "GET /works/329717/chapters/532070?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/329717/navigate?view_adult=true" "FLAG/2.1 (Webservice)"
      40.50.60.70 - - [14/Feb/2012:00:54:07 +0000] "GET /works/329717/chapters/532070?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/329717/chapters/532070?view_adult=true" "FLAG/2.1 (Webservice)"
      40.50.60.70 - - [14/Feb/2012:00:54:46 +0000] "GET /works/335295/navigate?view_adult=true HTTP/1.0" 302 161 "-" "FLAG/2.1 (Webservice)"
      40.50.60.70 - - [14/Feb/2012:00:54:46 +0000] "GET /works/335295/chapters/542036?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/335295/navigate?view_adult=true" "FLAG/2.1 (Webservice)"
      40.50.60.70 - - [14/Feb/2012:00:54:46 +0000] "GET /works/335295/chapters/542036?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/335295/chapters/542036?view_adult=true" "FLAG/2.1 (Webservice)"
      50.60.70.80 - - [14/Feb/2012:00:57:17 +0000] "GET /works/266440 HTTP/1.1" 302 161 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
      50.60.70.80 - - [14/Feb/2012:00:57:20 +0000] "GET /works/157752 HTTP/1.1" 302 161 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
      120.130.140.150 - - [14/Feb/2012:00:06:23 +0000] "GET /downloads/lallyloo/338985/Seeing%20Double.html HTTP/1.1" 200 12002 "http://archiveofourown.org/works/338985?view_adult=true" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"
      130.140.150.160 - - [14/Feb/2012:00:06:26 +0000] "GET /downloads/Closer/300812/My%20Brothers%20Keeper.epub HTTP/1.1" 200 70719 "http://archiveofourown.org/works/300812" "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7"
      140.150.160.170 - - [14/Feb/2012:00:08:37 +0000] "GET /downloads/Killashandra/73438/Full%20Circle.epub HTTP/1.1" 200 117134 "http://archiveofourown.org/works/73438" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"
      150.160.170.180 - - [14/Feb/2012:00:08:40 +0000] "GET /downloads/astolat/40561/The%20Crown%20of%20the%20Summer%20Court.epub HTTP/1.1" 200 56197 "http://archiveofourown.org/works/40561" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0) Gecko/20100101 Firefox/10.0"
      160.170.180.190 - - [14/Feb/2012:00:08:45 +0000] "GET /downloads/Killashandra/73437/Turning%20Point.epub HTTP/1.1" 200 70956 "http://archiveofourown.org/works/73437" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"
      170.180.190.200 - - [14/Feb/2012:00:09:03 +0000] "GET /downloads/Saucery/335284/And%20Lo%20They%20Beat%20Again%20These.html HTTP/1.1" 304 0 "http://archiveofourown.org/works/335284?view_full_work=true" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
      200.210.220.230 - - [14/Feb/2012:01:49:20 +0000] "GET /chapters/519375?page=1 HTTP/1.1" 302 161 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:8.0.1) Gecko/20100101 Firefox/8.0.1"
      200.210.220.230 - - [14/Feb/2012:01:49:20 +0000] "GET /chapters/519375?page=1 HTTP/1.1" 302 161 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:8.0.1) Gecko/20100101 Firefox/8.0.1"
      '

      logfile_content_feb_17 = '
      10.20.30.40 - - [17/Feb/2012:00:06:00 +0000] "GET /downloads/Cleo2010/191915/The%20Perfect%20Specimen%20Part.pdf HTTP/1.1" 200 127125 "http://archiveofourown.org/works/191915?view_full_work=true" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"
      10.20.30.40 - - [17/Feb/2012:00:06:00 +0000] "GET /downloads/Cleo2010/191915/The%20Perfect%20Specimen%20Part.pdf HTTP/1.1" 206 32768 "http://archiveofourown.org/downloads/Cleo2010/191915/The%20Perfect%20Specimen%20Part.pdf" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"
      10.20.30.40 - - [17/Feb/2012:00:06:00 +0000] "GET /downloads/Cleo2010/191915/The%20Perfect%20Specimen%20Part.pdf HTTP/1.1" 206 115263 "http://archiveofourown.org/downloads/Cleo2010/191915/The%20Perfect%20Specimen%20Part.pdf" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"
      20.30.40.50 - - [17/Feb/2012:00:06:07 +0000] "GET /downloads/saucyminx/307418/You%20Hold%20Me%20Without%20Touch.pdf HTTP/1.1" 200 313977 "http://archiveofourown.org/works/307418/chapters/491786" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7"
      30.40.50.60 - - [17/Feb/2012:00:06:11 +0000] "GET /downloads/lemniciate/82657/Whispers%20in%20the%20Dark.pdf HTTP/1.1" 200 15635 "-" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; WOW64; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506; Media Center PC 5.0)"
      60.70.80.90 - - [17/Feb/2012:00:24:11 +0000] "GET /works/149157 HTTP/1.1" 302 161 "-" "Mozilla/5.0 (Windows NT 6.1; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
      70.80.90.100 - - [17/Feb/2012:00:25:07 +0000] "GET /works/214229 HTTP/1.1" 302 161 "http://hawaiificfinder.livejournal.com/142077.html" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)"
      80.90.100.110 - - [17/Feb/2012:00:30:35 +0000] "GET /works?page=8 HTTP/1.1" 408 0 "-" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.9 (KHTML, like Gecko) Version/4.0.3 Safari/531.9"
      90.100.110.120 - - [17/Feb/2012:00:32:32 +0000] "GET /works?utf8=%E2%9C%93&selected_tags%5Brating%5D%5B%5D=13&selected_tags%5Btags%5D%5B%5D=23&selected_tags%5Btags%5D%5B%5D=25486&language_id=&boolean_type=and&commit=Filter+Works&tag_id=Actor+RPF HTTP/1.1" 408 0 "http://archiveofourown.org/tags/Actor%20RPF/works" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"
      100.110.120.130 - - [17/Feb/2012:00:35:26 +0000] "GET /works/250109/chapters/388095?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/250109/chapters/386729?view_adult=true" "FLAG/2.2 (webservice; http://www.flagfic.com/)"
      110.120.130.140 - - [17/Feb/2012:00:35:26 +0000] "GET /works/250109/chapters/387327?view_adult=true HTTP/1.0" 302 161 "http://archiveofourown.org/works/250109/chapters/386729?view_adult=true" "FLAG/2.2 (webservice; http://www.flagfic.com/)"
      180.190.200.210 - - [17/Feb/2012:00:43:29 +0000] "GET /chapters/158429?page=1&show_comments=true HTTP/1.1" 302 161 "http://www.facebook.com/l.php?u=http%3A%2F%2Fwww.archiveofourown.org%2Fchapters%2F158429%3Fpage%3D1%26show_comments%3Dtrue%23comment_616914&h=7AQHqhN-RAQFBJju-SZ2-9OGSvvowsua_Ypd48ZpNNqs1hA&enc=AZMQee5SSDaIt_JRTwX7WKDZzgpEQOlASLnitYgM8pzngcpbzuImqAmOUMif4kpRW2HZJ7g-e628j1JgJU37cdfLOWjFZdwttBg-Vi16Z0bGY1RZ5Nba0Pnf18dCYOQPwvw" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7"
      190.200.210.220 - - [17/Feb/2012:14:55:32 +0000] "GET /chapters/513801?show_comments=true HTTP/1.1" 408 0 "http://archiveofourown.org/works/319556?add_comment_reply_id=618220&show_comments=true" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7"
      '

      # set up the logfiles with mtimes slightly more recent than their content
      content_for_file("default.log.1", logfile_content_feb_14)
      content_for_file("default.log.2", logfile_content_feb_17)
      mtime_for_file("default.log.1", Date.parse("15/Feb/2012").to_time)
      mtime_for_file("default.log.2", Date.parse("18/Feb/2012").to_time)

    end

    it "gets the correct logfiles with no start date" do
      results = self.class.logfiles_to_read
      expect(results.size).to eq(2)
      expect(results).to include(LogfileReader::LOGFILE_DIR + "default.log.1")
      expect(results).to include(LogfileReader::LOGFILE_DIR + "default.log.2")
    end

    it "gets the correct logfiles given a start date" do
      start_date = Date.parse("16/Feb/2012").to_time
      results = self.class.logfiles_to_read(start_date)
      expect(results.size).to eq(1)
      expect(results.first).to eq(LogfileReader::LOGFILE_DIR + "default.log.2")
    end

    it "reads rows correctly with various patterns" do
      rows = self.class.rows_from_logfile(LogfileReader::LOGFILE_DIR + "default.log.1", "GET")
      expect(rows.size).to eq(16) # number of rows in first logfile
      rows = self.class.rows_from_logfile(LogfileReader::LOGFILE_DIR + "default.log.1", "GET /downloads")
      expect(rows.size).to eq(6)
      rows = self.class.rows_from_logfile(LogfileReader::LOGFILE_DIR + "default.log.1", 'GET /(?:works|chapters)/[0-9]+(?:/chapters/[0-9]+)?/?(?:\s|\?)')
      expect(rows.size).to eq(8)
    end
  end
end
