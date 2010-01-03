require 'optparse'

class ProjectSearch
  attr_reader :arguments
  attr_reader :scope
  attr_reader :term

  def initialize(args)
    @arguments = args
    parse_options
  end

  def search
    paths = case scope
      when "all" then
        %w(app config lib test public)
      when "code" then
        Dir[File.join("app", "*")] - [File.join("app", "views")] + %w(config lib test)
      when "css" then
        [File.join("public", "stylesheets")]
      when "js" then
        # "js" scope includes app/views because there may be javascripts in the views
        [File.join("public", "stylesheets"), File.join("app", "views")]
      when *%w(helper model presenter service view controller concern) then
        [File.join("app", "#{scope}s")]
      else
        [scope]
    end

    exts = %w(rb rjs rhtml rxml erb builder css js html haml sass).join(',')
    globs = paths.map { |path| File.join(path, "**", "*.{#{exts}}") }

    globs.each do |glob|
      Dir.glob(glob).each do |file|
        number = 1
        IO.foreach(file) do |line|
          puts "%s:%d:%s" % [file, number, line] if line =~ term
          number += 1
        end
      end
    end
  end

  private

    def parse_options
      parser = prepare_option_parser
      parser.parse!(arguments)

      @scope = arguments.shift or abort(parser.to_s)
      @term = arguments.shift

      @scope, @term = "all", @scope if @term.nil?
      @term = Regexp.new(@term)
    end

    def prepare_option_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] [scope] term"
        opts.separator ""

        opts.on <<EOF
  The project searcher is like a Rails-aware grep that can be
  used to quickly search specific areas of your project. Even
  if you're already proficient with the Unix find and grep
  commands, this finder tool can save you precious key-strokes.

  You invoke the command with an optional "scope", and a "term"
  (a regular expression pattern) to search for. If the scope is
  omitted, it defaults to "all". The supported scopes and their
  meanings are:

  * "all": search app, config, lib, test, and public directories.
  * "code": search app (except for app/views), config, lib, and
    test.
  * "css": search just the public/stylesheets directory.
  * "js": search just the public/javascripts directory.

  You can also specify "helper", "model", "presenter", "service",
  "view" "controller", or "concern", which will search in the
  pluralized version of that directory under "app".

  Any other scope argument is interpreted to mean the directory
  name itself that you want to search.

  Note that only files with the following extensions are searched:
  rb, rjs, rhtml, rxml, erb, builder, haml, css, sass, js, and html.

Examples:

    # searches all significant project directories for files that
    # contain the string "FIXME".
    #{$0} FIXME

    # searches all javascript and view files for Ajax.Request.
    #{$0} js Ajax.Request

    # searches the project's helpers for all method definitions
    # starting with "emit_":
    #{$0} helper "def emit_"
EOF

        opts.on "Options:"

        opts.on "-h", "--help", "Show this help message" do
          puts opts
          exit
        end
      end
    end
end
