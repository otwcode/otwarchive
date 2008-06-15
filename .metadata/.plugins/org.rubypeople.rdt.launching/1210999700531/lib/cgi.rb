=begin
------------------------------------------------------------- Class: CGI
     CGI class. See documentation for the file cgi.rb for an overview of
     the CGI protocol.


Introduction
------------
     CGI is a large class, providing several categories of methods, many
     of which are mixed in from other modules. Some of the documentation
     is in this class, some in the modules CGI::QueryExtension and
     CGI::HtmlExtension. See CGI::Cookie for specific information on
     handling cookies, and cgi/session.rb (CGI::Session) for information
     on sessions.

     For queries, CGI provides methods to get at environmental
     variables, parameters, cookies, and multipart request data. For
     responses, CGI provides methods for writing output and generating
     HTML.

     Read on for more details. Examples are provided at the bottom.


Queries
-------
     The CGI class dynamically mixes in parameter and cookie-parsing
     functionality, environmental variable access, and support for
     parsing multipart requests (including uploaded files) from the
     CGI::QueryExtension module.

     Environmental Variables
     The standard CGI environmental variables are available as read-only
     attributes of a CGI object. The following is a list of these
     variables:

       AUTH_TYPE               HTTP_HOST          REMOTE_IDENT
       CONTENT_LENGTH          HTTP_NEGOTIATE     REMOTE_USER
       CONTENT_TYPE            HTTP_PRAGMA        REQUEST_METHOD
       GATEWAY_INTERFACE       HTTP_REFERER       SCRIPT_NAME
       HTTP_ACCEPT             HTTP_USER_AGENT    SERVER_NAME
       HTTP_ACCEPT_CHARSET     PATH_INFO          SERVER_PORT
       HTTP_ACCEPT_ENCODING    PATH_TRANSLATED    SERVER_PROTOCOL
       HTTP_ACCEPT_LANGUAGE    QUERY_STRING       SERVER_SOFTWARE
       HTTP_CACHE_CONTROL      REMOTE_ADDR
       HTTP_FROM               REMOTE_HOST

     For each of these variables, there is a corresponding attribute
     with the same name, except all lower case and without a preceding
     HTTP_. +content_length+ and +server_port+ are integers; the rest
     are strings.

     Parameters
     The method #params() returns a hash of all parameters in the
     request as name/value-list pairs, where the value-list is an Array
     of one or more values. The CGI object itself also behaves as a hash
     of parameter names to values, but only returns a single value (as a
     String) for each parameter name.

     For instance, suppose the request contains the parameter
     "favourite_colours" with the multiple values "blue" and "green".
     The following behaviour would occur:

       cgi.params["favourite_colours"]  # => ["blue", "green"]
       cgi["favourite_colours"]         # => "blue"

     If a parameter does not exist, the former method will return an
     empty array, the latter an empty string. The simplest way to test
     for existence of a parameter is by the #has_key? method.

     Cookies
     HTTP Cookies are automatically parsed from the request. They are
     available from the #cookies() accessor, which returns a hash from
     cookie name to CGI::Cookie object.

     Multipart requests
     If a request's method is POST and its content type is
     multipart/form-data, then it may contain uploaded files. These are
     stored by the QueryExtension module in the parameters of the
     request. The parameter name is the name attribute of the file input
     field, as usual. However, the value is not a string, but an IO
     object, either an IOString for small files, or a Tempfile for
     larger ones. This object also has the additional singleton methods:

     #local_path():        the path of the uploaded file on the local
                           filesystem

     #original_filename(): the name of the file on the client computer

     #content_type():      the content type of the file


Responses
---------
     The CGI class provides methods for sending header and content
     output to the HTTP client, and mixes in methods for programmatic
     HTML generation from CGI::HtmlExtension and CGI::TagMaker modules.
     The precise version of HTML to use for HTML generation is specified
     at object creation time.

     Writing output
     The simplest way to send output to the HTTP client is using the
     #out() method. This takes the HTTP headers as a hash parameter, and
     the body content via a block. The headers can be generated as a
     string using the #header() method. The output stream can be written
     directly to using the #print() method.

     Generating HTML
     Each HTML element has a corresponding method for generating that
     element as a String. The name of this method is the same as that of
     the element, all lowercase. The attributes of the element are
     passed in as a hash, and the body as a no-argument block that
     evaluates to a String. The HTML generation module knows which
     elements are always empty, and silently drops any passed-in body.
     It also knows which elements require matching closing tags and
     which don't. However, it does not know what attributes are legal
     for which elements.

     There are also some additional HTML generation methods mixed in
     from the CGI::HtmlExtension module. These include individual
     methods for the different types of form inputs, and methods for
     elements that commonly take particular attributes where the
     attributes can be directly specified as arguments, rather than via
     a hash.


Examples of use
---------------
     Get form values
       require "cgi"
       cgi = CGI.new
       value = cgi['field_name']   # <== value string for 'field_name'
         # if not 'field_name' included, then return "".
       fields = cgi.keys            # <== array of field names
     
       # returns true if form has 'field_name'
       cgi.has_key?('field_name')
       cgi.has_key?('field_name')
       cgi.include?('field_name')

     CAUTION! cgi['field_name'] returned an Array with the old
     cgi.rb(included in ruby 1.6)

     Get form values as hash
       require "cgi"
       cgi = CGI.new
       params = cgi.params

     cgi.params is a hash.

       cgi.params['new_field_name'] = ["value"]  # add new param
       cgi.params['field_name'] = ["new_value"]  # change value
       cgi.params.delete('field_name')           # delete param
       cgi.params.clear                          # delete all params

     Save form values to file
       require "pstore"
       db = PStore.new("query.db")
       db.transaction do
         db["params"] = cgi.params
       end

     Restore form values from file
       require "pstore"
       db = PStore.new("query.db")
       db.transaction do
         cgi.params = db["params"]
       end

     Get multipart form values
       require "cgi"
       cgi = CGI.new
       value = cgi['field_name']   # <== value string for 'field_name'
       value.read                  # <== body of value
       value.local_path            # <== path to local file of value
       value.original_filename     # <== original filename of value
       value.content_type          # <== content_type of value

     and value has StringIO or Tempfile class methods.

     Get cookie values
       require "cgi"
       cgi = CGI.new
       values = cgi.cookies['name']  # <== array of 'name'
         # if not 'name' included, then return [].
       names = cgi.cookies.keys      # <== array of cookie names

     and cgi.cookies is a hash.

     Get cookie objects
       require "cgi"
       cgi = CGI.new
       for name, cookie in cgi.cookies
         cookie.expires = Time.now + 30
       end
       cgi.out("cookie" => cgi.cookies) {"string"}
     
       cgi.cookies # { "name1" => cookie1, "name2" => cookie2, ... }
     
       require "cgi"
       cgi = CGI.new
       cgi.cookies['name'].expires = Time.now + 30
       cgi.out("cookie" => cgi.cookies['name']) {"string"}

     Print http header and html string to $DEFAULT_OUTPUT ($>)
       require "cgi"
       cgi = CGI.new("html3")  # add HTML generation methods
       cgi.out() do
         cgi.html() do
           cgi.head{ cgi.title{"TITLE"} } +
           cgi.body() do
             cgi.form() do
               cgi.textarea("get_text") +
               cgi.br +
               cgi.submit
             end +
             cgi.pre() do
               CGI::escapeHTML(
                 "params: " + cgi.params.inspect + "\n" +
                 "cookies: " + cgi.cookies.inspect + "\n" +
                 ENV.collect() do |key, value|
                   key + " --> " + value + "\n"
                 end.join("")
               )
             end
           end
         end
       end
     
       # add HTML generation methods
       CGI.new("html3")    # html3.2
       CGI.new("html4")    # html4.01 (Strict)
       CGI.new("html4Tr")  # html4.01 Transitional
       CGI.new("html4Fr")  # html4.01 Frameset

------------------------------------------------------------------------
     TODO: document how this differs from stdlib CGI::Cookie

------------------------------------------------------------------------


Constants:
----------
     CR:            "\015"
     EOL:           CR + LF
     LF:            "\012"
     RFC822_DAYS:   %w[ Sun Mon Tue Wed Thu Fri Sat ]
     RFC822_MONTHS: %w[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
                    ]


Class methods:
--------------
     cookie, error, escape, escapeElement, escapeHTML, header, message,
     new, parse, pretty, print, rfc1123_date, tag, unescape,
     unescapeElement, unescapeHTML


Instance methods:
-----------------
     env_table, header, out, print, read_from_cmdline, stdinput,
     stdoutput

Attributes:
     cookie, inputs

=end
class CGI < Object

  # ------------------------------------------------------------ CGI::escape
  #      CGI::escape(str)
  # ------------------------------------------------------------------------
  #      escape url encode
  # 
  def self.escape(arg0)
  end

  # ----------------------------------------------------- CGI::escapeElement
  #      CGI::escapeElement(string, *elements)
  # ------------------------------------------------------------------------
  #      Escape only the tags of certain HTML elements in +string+.
  # 
  #      Takes an element or elements or array of elements. Each element is
  #      specified by the name of the element, without angle brackets. This
  #      matches both the start and the end tag of that element. The
  #      attribute list of the open tag will also be escaped (for instance,
  #      the double-quotes surrounding attribute values).
  # 
  #        print CGI::escapeElement('<BR><A HREF="url"></A>', "A", "IMG")
  #          # "<BR>&lt;A HREF=&quot;url&quot;&gt;&lt;/A&gt"
  #      
  #        print CGI::escapeElement('<BR><A HREF="url"></A>', ["A", "IMG"])
  #          # "<BR>&lt;A HREF=&quot;url&quot;&gt;&lt;/A&gt"
  # 
  def self.escapeElement(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------ CGI::pretty
  #      CGI::pretty(string, shift = " ")
  # ------------------------------------------------------------------------
  #      Prettify (indent) an HTML string.
  # 
  #      +string+ is the HTML string to indent. +shift+ is the indentation
  #      unit to use; it defaults to two spaces.
  # 
  #        print CGI::pretty("<HTML><BODY></BODY></HTML>")
  #          # <HTML>
  #          #   <BODY>
  #          #   </BODY>
  #          # </HTML>
  #      
  #        print CGI::pretty("<HTML><BODY></BODY></HTML>", "\t")
  #          # <HTML>
  #          #         <BODY>
  #          #         </BODY>
  #          # </HTML>
  # 
  def self.pretty(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------ CGI::rfc1123_date
  #      CGI::rfc1123_date(time)
  # ------------------------------------------------------------------------
  #      make rfc1123 date string
  # 
  def self.rfc1123_date(arg0)
  end

  # ------------------------------------------------------ CGI::unescapeHTML
  #      CGI::unescapeHTML(string)
  # ------------------------------------------------------------------------
  #      Unescape a string that has been HTML-escaped
  # 
  #        CGI::unescapeHTML("Usage: foo &quot;bar&quot; &lt;baz&gt;")
  #           # => "Usage: foo \"bar\" <baz>"
  # 
  def self.unescapeHTML(arg0)
  end

  # --------------------------------------------------- CGI::unescapeElement
  #      CGI::unescapeElement(string, *elements)
  # ------------------------------------------------------------------------
  #      Undo escaping such as that done by CGI::escapeElement()
  # 
  #        print CGI::unescapeElement(
  #                CGI::escapeHTML('<BR><A HREF="url"></A>'), "A", "IMG")
  #          # "&lt;BR&gt;<A HREF="url"></A>"
  #      
  #        print CGI::unescapeElement(
  #                CGI::escapeHTML('<BR><A HREF="url"></A>'), ["A", "IMG"])
  #          # "&lt;BR&gt;<A HREF="url"></A>"
  # 
  def self.unescapeElement(arg0, arg1, arg2, *rest)
  end

  # -------------------------------------------------------- CGI::escapeHTML
  #      CGI::escapeHTML(string)
  # ------------------------------------------------------------------------
  #      Escape special characters in HTML, namely &\"<>
  # 
  #        CGI::escapeHTML('Usage: foo "bar" <baz>')
  #           # => "Usage: foo &quot;bar&quot; &lt;baz&gt;"
  # 
  def self.escapeHTML(arg0)
  end

  # ---------------------------------------------------------- CGI::unescape
  #      CGI::unescape(str)
  # ------------------------------------------------------------------------
  #      unescape url encoded
  # 
  def self.unescape(arg0)
  end

  # ------------------------------------------------------------- CGI::parse
  #      CGI::parse(query)
  # ------------------------------------------------------------------------
  #      Parse an HTTP query string into a hash of key=>value pairs.
  # 
  #        params = CGI::parse("query_string")
  #          # {"name1" => ["value1", "value2", ...],
  #          #  "name2" => ["value1", "value2", ...], ... }
  # 
  def self.parse(arg0)
  end

  # ---------------------------------------------------------------- CGI#out
  #      out(options = "text/html") {|| ...}
  # ------------------------------------------------------------------------
  #      Print an HTTP header and body to $DEFAULT_OUTPUT ($>)
  # 
  #      The header is provided by +options+, as for #header(). The body of
  #      the document is that returned by the passed- in block. This block
  #      takes no arguments. It is required.
  # 
  #        cgi = CGI.new
  #        cgi.out{ "string" }
  #          # Content-Type: text/html
  #          # Content-Length: 6
  #          #
  #          # string
  #      
  #        cgi.out("text/plain") { "string" }
  #          # Content-Type: text/plain
  #          # Content-Length: 6
  #          #
  #          # string
  #      
  #        cgi.out("nph"        => true,
  #                "status"     => "OK",  # == "200 OK"
  #                "server"     => ENV['SERVER_SOFTWARE'],
  #                "connection" => "close",
  #                "type"       => "text/html",
  #                "charset"    => "iso-2022-jp",
  #                  # Content-Type: text/html; charset=iso-2022-jp
  #                "language"   => "ja",
  #                "expires"    => Time.now + (3600 * 24 * 30),
  #                "cookie"     => [cookie1, cookie2],
  #                "my_header1" => "my_value",
  #                "my_header2" => "my_value") { "string" }
  # 
  #      Content-Length is automatically calculated from the size of the
  #      String returned by the content block.
  # 
  #      If ENV['REQUEST_METHOD'] == "HEAD", then only the header is
  #      outputted (the content block is still required, but it is ignored).
  # 
  #      If the charset is "iso-2022-jp" or "euc-jp" or "shift_jis" then the
  #      content is converted to this charset, and the language is set to
  #      "ja".
  # 
  def out(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- CGI#print
  #      print(*options)
  # ------------------------------------------------------------------------
  #      Print an argument or list of arguments to the default output stream
  # 
  #        cgi = CGI.new
  #        cgi.print    # default:  cgi.print == $DEFAULT_OUTPUT.print
  # 
  def print(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- CGI#header
  #      header(options = "text/html")
  # ------------------------------------------------------------------------
  #      Create an HTTP header block as a string.
  # 
  #      Includes the empty line that ends the header block.
  # 
  #      +options+ can be a string specifying the Content-Type (defaults to
  #      text/html), or a hash of header key/value pairs. The following
  #      header keys are recognized:
  # 
  #      type:       the Content-Type header. Defaults to "text/html"
  # 
  #      charset:    the charset of the body, appended to the Content-Type
  #                  header.
  # 
  #      nph:        a boolean value. If true, prepend protocol string and
  #                  status code, and date; and sets default values for
  #                  "server" and "connection" if not explicitly set.
  # 
  #      status:     the HTTP status code, returned as the Status header.
  #                  See the list of available status codes below.
  # 
  #      server:     the server software, returned as the Server header.
  # 
  #      connection: the connection type, returned as the Connection header
  #                  (for instance, "close".
  # 
  #      length:     the length of the content that will be sent, returned
  #                  as the Content-Length header.
  # 
  #      language:   the language of the content, returned as the
  #                  Content-Language header.
  # 
  #      expires:    the time on which the current content expires, as a
  #                  +Time+ object, returned as the Expires header.
  # 
  #      cookie:     a cookie or cookies, returned as one or more Set-Cookie
  #                  headers. The value can be the literal string of the
  #                  cookie; a CGI::Cookie object; an Array of literal
  #                  cookie strings or Cookie objects; or a hash all of
  #                  whose values are literal cookie strings or Cookie
  #                  objects. These cookies are in addition to the cookies
  #                  held in the @output_cookies field.
  # 
  #      Other header lines can also be set; they are appended as key:
  #      value.
  # 
  #        header
  #          # Content-Type: text/html
  #      
  #        header("text/plain")
  #          # Content-Type: text/plain
  #      
  #        header("nph"        => true,
  #               "status"     => "OK",  # == "200 OK"
  #                 # "status"     => "200 GOOD",
  #               "server"     => ENV['SERVER_SOFTWARE'],
  #               "connection" => "close",
  #               "type"       => "text/html",
  #               "charset"    => "iso-2022-jp",
  #                 # Content-Type: text/html; charset=iso-2022-jp
  #               "length"     => 103,
  #               "language"   => "ja",
  #               "expires"    => Time.now + 30,
  #               "cookie"     => [cookie1, cookie2],
  #               "my_header1" => "my_value"
  #               "my_header2" => "my_value")
  # 
  #      The status codes are:
  # 
  #        "OK"                  --> "200 OK"
  #        "PARTIAL_CONTENT"     --> "206 Partial Content"
  #        "MULTIPLE_CHOICES"    --> "300 Multiple Choices"
  #        "MOVED"               --> "301 Moved Permanently"
  #        "REDIRECT"            --> "302 Found"
  #        "NOT_MODIFIED"        --> "304 Not Modified"
  #        "BAD_REQUEST"         --> "400 Bad Request"
  #        "AUTH_REQUIRED"       --> "401 Authorization Required"
  #        "FORBIDDEN"           --> "403 Forbidden"
  #        "NOT_FOUND"           --> "404 Not Found"
  #        "METHOD_NOT_ALLOWED"  --> "405 Method Not Allowed"
  #        "NOT_ACCEPTABLE"      --> "406 Not Acceptable"
  #        "LENGTH_REQUIRED"     --> "411 Length Required"
  #        "PRECONDITION_FAILED" --> "412 Precondition Failed"
  #        "SERVER_ERROR"        --> "500 Internal Server Error"
  #        "NOT_IMPLEMENTED"     --> "501 Method Not Implemented"
  #        "BAD_GATEWAY"         --> "502 Bad Gateway"
  #        "VARIANT_ALSO_VARIES" --> "506 Variant Also Negotiates"
  # 
  #      This method does not perform charset conversion.
  # 
  def header(arg0, arg1, *rest)
  end

end
