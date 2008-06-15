=begin
------------------------------------------------------------- Class: URI
     URI support for Ruby

     Author:        Akira Yamada <akira@ruby-lang.org>

     Documentation: Akira Yamada <akira@ruby-lang.org>, Dmitry V.
                    Sabanin <sdmitry@lrn.ru>

     License:       Copyright (c) 2001 akira yamada
                    <akira@ruby-lang.org> You can redistribute it and/or
                    modify it under the same term as Ruby.

     Revision:      $Id: uri.rb 11708 2007-02-12 23:01:19Z shyouhei $

     See URI for documentation

------------------------------------------------------------------------


Includes:
---------
     REGEXP


Class methods:
--------------
     extract, join, parse, regexp, split

=end
module URI
  include URI::REGEXP

  # ------------------------------------------------------------ URI::regexp
  #      URI::regexp(schemes = nil)
  # ------------------------------------------------------------------------
  # 
  # Synopsis
  # --------
  #        URI::regexp([match_schemes])
  # 
  # 
  # Args
  # ----
  #      +match_schemes+: Array of schemes. If given, resulting regexp
  #                       matches to URIs whose scheme is one of the
  #                       match_schemes.
  # 
  # 
  # Description
  # -----------
  #      Returns a Regexp object which matches to URI-like strings. The
  #      Regexp object returned by this method includes arbitrary number of
  #      capture group (parentheses). Never rely on it's number.
  # 
  # 
  # Usage
  # -----
  #        require 'uri'
  #      
  #        # extract first URI from html_string
  #        html_string.slice(URI.regexp)
  #      
  #        # remove ftp URIs
  #        html_string.sub(URI.regexp(['ftp'])
  #      
  #        # You should not rely on the number of parentheses
  #        html_string.scan(URI.regexp) do |*matches|
  #          p $&
  #        end
  # 
  def self.regexp(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- URI::join
  #      URI::join(*str)
  # ------------------------------------------------------------------------
  # 
  # Synopsis
  # --------
  #        URI::join(str[, str, ...])
  # 
  # 
  # Args
  # ----
  #      +str+: String(s) to work with
  # 
  # 
  # Description
  # -----------
  #      Joins URIs.
  # 
  # 
  # Usage
  # -----
  #        require 'uri'
  #      
  #        p URI.join("http://localhost/","main.rbx")
  #        # => #<URI::HTTP:0x2022ac02 URL:http://localhost/main.rbx>
  # 
  def self.join(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- URI::extract
  #      URI::extract(str, schemes = nil, &block) {|$&| ...}
  # ------------------------------------------------------------------------
  # 
  # Synopsis
  # --------
  #        URI::extract(str[, schemes][,&blk])
  # 
  # 
  # Args
  # ----
  #      +str+:     String to extract URIs from.
  # 
  #      +schemes+: Limit URI matching to a specific schemes.
  # 
  # 
  # Description
  # -----------
  #      Extracts URIs from a string. If block given, iterates through all
  #      matched URIs. Returns nil if block given or array with matches.
  # 
  # 
  # Usage
  # -----
  #        require "uri"
  #      
  #        URI.extract("text here http://foo.example.org/bla and here mailto:test@example.com and here also.")
  #        # => ["http://foo.example.com/bla", "mailto:test@example.com"]
  # 
  def self.extract(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------- URI::split
  #      URI::split(uri)
  # ------------------------------------------------------------------------
  # 
  # Synopsis
  # --------
  #        URI::split(uri)
  # 
  # 
  # Args
  # ----
  #      +uri+: String with URI.
  # 
  # 
  # Description
  # -----------
  #      Splits the string on following parts and returns array with result:
  # 
  #        * Scheme
  #        * Userinfo
  #        * Host
  #        * Port
  #        * Registry
  #        * Path
  #        * Opaque
  #        * Query
  #        * Fragment
  # 
  # 
  # Usage
  # -----
  #        require 'uri'
  #      
  #        p URI.split("http://www.ruby-lang.org/")
  #        # => ["http", nil, "www.ruby-lang.org", nil, nil, "/", nil, nil, nil]
  # 
  def self.split(arg0)
  end

  # ------------------------------------------------------------- URI::parse
  #      URI::parse(uri)
  # ------------------------------------------------------------------------
  # 
  # Synopsis
  # --------
  #        URI::parse(uri_str)
  # 
  # 
  # Args
  # ----
  #      +uri_str+: String with URI.
  # 
  # 
  # Description
  # -----------
  #      Creates one of the URI's subclasses instance from the string.
  # 
  # 
  # Raises
  # ------
  #      URI::InvalidURIError
  # 
  #        Raised if URI given is not a correct one.
  # 
  # 
  # Usage
  # -----
  #        require 'uri'
  #      
  #        uri = URI.parse("http://www.ruby-lang.org/")
  #        p uri
  #        # => #<URI::HTTP:0x202281be URL:http://www.ruby-lang.org/>
  #        p uri.scheme
  #        # => "http"
  #        p uri.host
  #        # => "www.ruby-lang.org"
  # 
  def self.parse(arg0)
  end

end
