=begin
------------------------------------------------------------ Class: YAML

YAML
----
     YAML(tm) (rhymes with 'camel') is a straightforward machine
     parsable data serialization format designed for human readability
     and interaction with scripting languages such as Perl and Python.
     YAML is optimized for data serialization, formatted dumping,
     configuration files, log files, Internet messaging and filtering.
     This specification describes the YAML information model and
     serialization format. Together with the Unicode standard for
     characters, it provides all the information necessary to understand
     YAML Version 1.0 and construct computer programs to process it.

     See http://yaml.org/ for more information. For a quick tutorial,
     please visit YAML In Five Minutes
     (http://yaml.kwiki.org/?YamlInFiveMinutes).


About This Library
------------------
     The YAML 1.0 specification outlines four stages of YAML loading and
     dumping. This library honors all four of those stages, although
     data is really only available to you in three stages.

     The four stages are: native, representation, serialization, and
     presentation.

     The native stage refers to data which has been loaded completely
     into Ruby's own types. (See +YAML::load+.)

     The representation stage means data which has been composed into
     +YAML::BaseNode+ objects. In this stage, the document is available
     as a tree of node objects. You can perform YPath queries and
     transformations at this level. (See +YAML::parse+.)

     The serialization stage happens inside the parser. The YAML parser
     used in Ruby is called Syck. Serialized nodes are available in the
     extension as SyckNode structs.

     The presentation stage is the YAML document itself. This is
     accessible to you as a string. (See +YAML::dump+.)

     For more information about the various information models, see
     Chapter 3 of the YAML 1.0 Specification
     (http://yaml.org/spec/#id2491269).

     The YAML module provides quick access to the most common loading
     (YAML::load) and dumping (YAML::dump) tasks. This module also
     provides an API for registering global types
     (YAML::add_domain_type).


Example
-------
     A simple round-trip (load and dump) of an object.

         require "yaml"
     
         test_obj = ["dogs", "cats", "badgers"]
     
         yaml_obj = YAML::dump( test_obj )
                             # -> ---
                                  - dogs
                                  - cats
                                  - badgers
         ruby_obj = YAML::load( yaml_obj )
                             # => ["dogs", "cats", "badgers"]
         ruby_obj == test_obj
                             # => true

     To register your custom types with the global resolver, use
     +add_domain_type+.

         YAML::add_domain_type( "your-site.com,2004", "widget" ) do |type, val|
             Widget.new( val )
         end

------------------------------------------------------------------------


Constants:
----------
     DEFAULTS:                   {                 :Indent => 2,
                                 :UseHeader => false, :UseVersion =>
                                 false, :Version => '1.0',              
                                   :SortKeys => false, :AnchorFormat =>
                                 'id%03d', :ExplicitTypes => false,     
                                            :WidthType => 'absolute',
                                 :BestWidth => 80,                
                                 :UseBlock => false, :UseFold => false,
                                 :Encoding => :None
     DNS_COMP_RE:                "\\w(?:[-\\w]*\\w)?"
     DNS_NAME_RE:                "(?:(?:#{DNS_COMP_RE}\\.)+#{DNS_COMP_RE
                                 }|#{DNS_COMP_RE})"
     DefaultResolver:            YAML::Syck::DefaultResolver
     ERROR_ANCHOR_ALIAS:         "Can't define both an anchor and an
                                 alias"
     ERROR_BAD_ALIAS:            "Invalid alias: %s"
     ERROR_BAD_ANCHOR:           "Invalid anchor: %s"
     ERROR_BAD_EXPLICIT:         "Unsupported explicit transfer: '%s'"
     ERROR_MANY_ALIAS:           "More than one alias"
     ERROR_MANY_ANCHOR:          "More than one anchor"
     ERROR_MANY_EXPLICIT:        "More than one explicit transfer"
     ERROR_MANY_IMPLICIT:        "More than one implicit request"
     ERROR_NEED_HEADER:          "With UseHeader=false, the node must be
                                 an Array or Hash"
     ERROR_NO_ANCHOR:            "No anchor for alias '%s'"
     ERROR_NO_HEADER_NODE:       "With UseHeader=false, the node Array
                                 or Hash must have elements"
     ERROR_UNSUPPORTED_ENCODING: "Attempt to use unsupported encoding:
                                 %s"
     ERROR_UNSUPPORTED_VERSION:  "This release of YAML.rb does not
                                 support YAML version %s"
     ERROR_ZERO_INDENT:          "Can't use zero as an indentation
                                 width"
     ESCAPES:                    %w{\x00   \x01       \x02  \x03    
                                 \x04        \x05   \x06      \a        
                                                      \x08    \t        
                                 \n             \v         \f           
                                  \r         \x0e   \x0f                
                                                  \x10       \x11  \x12 
                                    \x13        \x14   \x15      \x16
                                 \x17                                 
                                 \x18       \x19  \x1a     \e         
                                 \x1c    \x1d       \x1e  \x1f          
                                                   }
     ESCAPE_CHAR:                '[\\x00-\\x09\\x0b-\\x1f]'
     Emitter:                    YAML::Syck::Emitter
     GenericResolver:            YAML::Syck::GenericResolver
     INDICATOR_CHAR:             '*&!|\\\\^@%{}[]='
     NOT_PLAIN_CHAR:             '\x7f\x0-\x1f\x80-\x9f'
     PRINTABLE_CHAR:             '-_A-Za-z0-9!?/()$\'". '
     Parser:                     YAML::Syck::Parser
     RESTRICTED_INDICATORS:      '#:,}]'
     Resolver:                   YAML::Syck::Resolver
     SPACE_INDICATORS:           '-#:,?'
     SUPPORTED_YAML_VERSIONS:    ['1.0']
     UNESCAPES:                  {                                 'a'
                                 => "\x07", 'b' => "\x08", 't' =>
                                 "\x09",                                
                                  'n' => "\x0a", 'v' => "\x0b", 'f' =>
                                 "\x0c",                                
                                 'r' => "\x0d", 'e' => "\x1b", '\\' =>
                                 '\\',                             }
     VERSION:                    '0.60'
     WORD_CHAR:                  'A-Za-z0-9'


Class methods:
--------------
     add_builtin_type, add_domain_type, add_private_type, add_ruby_type,
     detect_implicit, dump, dump_stream, each_document, each_node,
     emitter, escape, generic_parser, load, load_documents, load_file,
     load_stream, make_stream, object_maker, parse, parse_documents,
     parse_file, parser, quick_emit, read_type_class, resolver,
     tag_class, tagged_classes, tagurize, transfer, try_implicit,
     unescape

=end
module YAML

  # ------------------------------------------------------ YAML::load_stream
  #      YAML::load_stream( io )
  # ------------------------------------------------------------------------
  #      Loads all documents from the current _io_ stream, returning a
  #      +YAML::Stream+ object containing all loaded documents.
  # 
  def self.load_stream(arg0)
  end

  # --------------------------------------------------------- YAML::resolver
  #      YAML::resolver()
  # ------------------------------------------------------------------------
  #      Returns the default resolver
  # 
  def self.resolver
  end

  # --------------------------------------------------- YAML::load_documents
  #      YAML::load_documents( io, &doc_proc )
  # ------------------------------------------------------------------------
  #      Calls _block_ with each consecutive document in the YAML stream
  #      contained in _io_.
  # 
  #        File.open( 'many-docs.yaml' ) do |yf|
  #          YAML.load_documents( yf ) do |ydoc|
  #            ## ydoc contains the single object
  #            ## from the YAML document
  #          end
  #        end
  # 
  def self.load_documents(arg0)
  end

  # -------------------------------------------------- YAML::add_domain_type
  #      YAML::add_domain_type( domain, type_tag, &transfer_proc )
  # ------------------------------------------------------------------------
  #      Add a global handler for a YAML domain type.
  # 
  def self.add_domain_type(arg0, arg1)
  end

  # --------------------------------------------------------- YAML::transfer
  #      YAML::transfer( type_id, obj )
  # ------------------------------------------------------------------------
  #      Apply a transfer method to a Ruby object
  # 
  def self.transfer(arg0, arg1)
  end

  # -------------------------------------------------------- YAML::load_file
  #      YAML::load_file( filepath )
  # ------------------------------------------------------------------------
  #      Load a document from the file located at _filepath_.
  # 
  #        YAML.load_file( 'animals.yaml' )
  #           #=> ['badger', 'elephant', 'tiger']
  # 
  def self.load_file(arg0)
  end

  # ------------------------------------------------- YAML::add_private_type
  #      YAML::add_private_type( type_re, &transfer_proc )
  # ------------------------------------------------------------------------
  #      Add a private document type
  # 
  def self.add_private_type(arg0)
  end

  # -------------------------------------------------------- YAML::tag_class
  #      YAML::tag_class( tag, cls )
  # ------------------------------------------------------------------------
  #      Associates a taguri _tag_ with a Ruby class _cls_. The taguri is
  #      used to give types to classes when loading YAML. Taguris are of the
  #      form:
  # 
  #        tag:authorityName,date:specific
  # 
  #      The +authorityName+ is a domain name or email address. The +date+
  #      is the date the type was issued in YYYY or YYYY-MM or YYYY-MM-DD
  #      format. The +specific+ is a name for the type being added.
  # 
  #      For example, built-in YAML types have 'yaml.org' as the
  #      +authorityName+ and '2002' as the +date+. The +specific+ is simply
  #      the name of the type:
  # 
  #       tag:yaml.org,2002:int
  #       tag:yaml.org,2002:float
  #       tag:yaml.org,2002:timestamp
  # 
  #      The domain must be owned by you on the +date+ declared. If you
  #      don't own any domains on the date you declare the type, you can
  #      simply use an e-mail address.
  # 
  #       tag:why@ruby-lang.org,2004:notes/personal
  # 
  def self.tag_class(arg0, arg1)
  end

  # -------------------------------------------------- YAML::parse_documents
  #      YAML::parse_documents( io, &doc_proc )
  # ------------------------------------------------------------------------
  #      Calls _block_ with a tree of +YAML::BaseNodes+, one tree for each
  #      consecutive document in the YAML stream contained in _io_.
  # 
  #        File.open( 'many-docs.yaml' ) do |yf|
  #          YAML.parse_documents( yf ) do |ydoc|
  #            ## ydoc contains a tree of nodes
  #            ## from the YAML document
  #          end
  #        end
  # 
  def self.parse_documents(arg0)
  end

  # -------------------------------------------------- YAML::read_type_class
  #      YAML::read_type_class( type, obj_class )
  # ------------------------------------------------------------------------
  #      Method to extract colon-seperated type and class, returning the
  #      type and the constant of the class
  # 
  def self.read_type_class(arg0, arg1)
  end

  # ---------------------------------------------------- YAML::each_document
  #      YAML::each_document( io, &block )
  # ------------------------------------------------------------------------
  #      Calls _block_ with each consecutive document in the YAML stream
  #      contained in _io_.
  # 
  #        File.open( 'many-docs.yaml' ) do |yf|
  #          YAML.each_document( yf ) do |ydoc|
  #            ## ydoc contains the single object
  #            ## from the YAML document
  #          end
  #        end
  # 
  def self.each_document(arg0)
  end

  # --------------------------------------------------------- YAML::tagurize
  #      YAML::tagurize( val )
  # ------------------------------------------------------------------------
  #      Convert a type_id to a taguri
  # 
  def self.tagurize(arg0)
  end

  # --------------------------------------------------- YAML::tagged_classes
  #      YAML::tagged_classes()
  # ------------------------------------------------------------------------
  #      Returns the complete dictionary of taguris, paired with classes.
  #      The key for the dictionary is the full taguri. The value for each
  #      key is the class constant associated to that taguri.
  # 
  #       YAML.tagged_classes["tag:yaml.org,2002:int"] => Integer
  # 
  def self.tagged_classes
  end

  # ---------------------------------------------------- YAML::add_ruby_type
  #      YAML::add_ruby_type( type_tag, &transfer_proc )
  # ------------------------------------------------------------------------
  #      Add a transfer method for a builtin type
  # 
  def self.add_ruby_type(arg0)
  end

  # ----------------------------------------------------- YAML::object_maker
  #      YAML::object_maker( obj_class, val )
  # ------------------------------------------------------------------------
  #      Allocate blank object
  # 
  def self.object_maker(arg0, arg1)
  end

  # ---------------------------------------------------------- YAML::emitter
  #      YAML::emitter()
  # ------------------------------------------------------------------------
  #      Returns a new default emitter
  # 
  def self.emitter
  end

  # -------------------------------------------------------- YAML::each_node
  #      YAML::each_node( io, &doc_proc )
  # ------------------------------------------------------------------------
  #      Calls _block_ with a tree of +YAML::BaseNodes+, one tree for each
  #      consecutive document in the YAML stream contained in _io_.
  # 
  #        File.open( 'many-docs.yaml' ) do |yf|
  #          YAML.each_node( yf ) do |ydoc|
  #            ## ydoc contains a tree of nodes
  #            ## from the YAML document
  #          end
  #        end
  # 
  def self.each_node(arg0)
  end

  # ----------------------------------------------------- YAML::try_implicit
  #      YAML::try_implicit( obj )
  # ------------------------------------------------------------------------
  #      Apply any implicit a node may qualify for
  # 
  def self.try_implicit(arg0)
  end

  # ----------------------------------------------------------- YAML::parser
  #      YAML::parser()
  # ------------------------------------------------------------------------
  #      Returns a new default parser
  # 
  def self.parser
  end

  # ------------------------------------------------------- YAML::parse_file
  #      YAML::parse_file( filepath )
  # ------------------------------------------------------------------------
  #      Parse a document from the file located at _filepath_.
  # 
  #        YAML.parse_file( 'animals.yaml' )
  #           #=> #<YAML::Syck::Node:0x82ccce0
  #                @kind=:seq,
  #                @value=
  #                 [#<YAML::Syck::Node:0x82ccd94
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="badger">,
  #                  #<YAML::Syck::Node:0x82ccd58
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="elephant">,
  #                  #<YAML::Syck::Node:0x82ccd1c
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="tiger">]>
  # 
  def self.parse_file(arg0)
  end

  # -------------------------------------------------- YAML::detect_implicit
  #      YAML::detect_implicit( val )
  # ------------------------------------------------------------------------
  #      Detect typing of a string
  # 
  def self.detect_implicit(arg0)
  end

  # ------------------------------------------------------------- YAML::load
  #      YAML::load( io )
  # ------------------------------------------------------------------------
  #      Load a document from the current _io_ stream.
  # 
  #        File.open( 'animals.yaml' ) { |yf| YAML::load( yf ) }
  #           #=> ['badger', 'elephant', 'tiger']
  # 
  #      Can also load from a string.
  # 
  #        YAML.load( "--- :locked" )
  #           #=> :locked
  # 
  def self.load(arg0)
  end

  # ------------------------------------------------- YAML::add_builtin_type
  #      YAML::add_builtin_type( type_tag, &transfer_proc )
  # ------------------------------------------------------------------------
  #      Add a transfer method for a builtin type
  # 
  def self.add_builtin_type(arg0)
  end

  # --------------------------------------------------- YAML::generic_parser
  #      YAML::generic_parser()
  # ------------------------------------------------------------------------
  #      Returns a new generic parser
  # 
  def self.generic_parser
  end

  # ------------------------------------------------------------- YAML::dump
  #      YAML::dump( obj, io = nil )
  # ------------------------------------------------------------------------
  #      Converts _obj_ to YAML and writes the YAML result to _io_.
  # 
  #        File.open( 'animals.yaml', 'w' ) do |out|
  #          YAML.dump( ['badger', 'elephant', 'tiger'], out )
  #        end
  # 
  #      If no _io_ is provided, a string containing the dumped YAML is
  #      returned.
  # 
  #        YAML.dump( :locked )
  #           #=> "--- :locked"
  # 
  def self.dump(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------ YAML::parse
  #      YAML::parse( io )
  # ------------------------------------------------------------------------
  #      Parse the first document from the current _io_ stream
  # 
  #        File.open( 'animals.yaml' ) { |yf| YAML::load( yf ) }
  #           #=> #<YAML::Syck::Node:0x82ccce0
  #                @kind=:seq,
  #                @value=
  #                 [#<YAML::Syck::Node:0x82ccd94
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="badger">,
  #                  #<YAML::Syck::Node:0x82ccd58
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="elephant">,
  #                  #<YAML::Syck::Node:0x82ccd1c
  #                   @kind=:scalar,
  #                   @type_id="str",
  #                   @value="tiger">]>
  # 
  #      Can also load from a string.
  # 
  #        YAML.parse( "--- :locked" )
  #           #=> #<YAML::Syck::Node:0x82edddc
  #                 @type_id="tag:ruby.yaml.org,2002:sym",
  #                 @value=":locked", @kind=:scalar>
  # 
  def self.parse(arg0)
  end

  # ------------------------------------------------------ YAML::dump_stream
  #      YAML::dump_stream( *objs )
  # ------------------------------------------------------------------------
  #      Returns a YAML stream containing each of the items in +objs+, each
  #      having their own document.
  # 
  #        YAML.dump_stream( 0, [], {} )
  #          #=> --- 0
  #              --- []
  #              --- {}
  # 
  def self.dump_stream(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- YAML::quick_emit
  #      YAML::quick_emit( oid, opts = {}, &e )
  # ------------------------------------------------------------------------
  #      Allocate an Emitter if needed
  # 
  def self.quick_emit(arg0, arg1, arg2, *rest)
  end

end
