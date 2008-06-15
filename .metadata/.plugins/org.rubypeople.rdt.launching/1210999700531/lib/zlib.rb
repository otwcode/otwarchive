=begin
------------------------------------------------------------ Class: Zlib
     GZIP_SUPPORT

------------------------------------------------------------------------


Constants:
----------
     VERSION:             rb_str_new2(RUBY_ZLIB_VERSION)
     ZLIB_VERSION:        rb_str_new2(ZLIB_VERSION)
     BINARY:              INT2FIX(Z_BINARY)
     ASCII:               INT2FIX(Z_ASCII)
     UNKNOWN:             INT2FIX(Z_UNKNOWN)
     NO_COMPRESSION:      INT2FIX(Z_NO_COMPRESSION)
     BEST_SPEED:          INT2FIX(Z_BEST_SPEED)
     BEST_COMPRESSION:    INT2FIX(Z_BEST_COMPRESSION)
     DEFAULT_COMPRESSION: INT2FIX(Z_DEFAULT_COMPRESSION)
     FILTERED:            INT2FIX(Z_FILTERED)
     HUFFMAN_ONLY:        INT2FIX(Z_HUFFMAN_ONLY)
     DEFAULT_STRATEGY:    INT2FIX(Z_DEFAULT_STRATEGY)
     MAX_WBITS:           INT2FIX(MAX_WBITS)
     DEF_MEM_LEVEL:       INT2FIX(DEF_MEM_LEVEL)
     MAX_MEM_LEVEL:       INT2FIX(MAX_MEM_LEVEL)
     NO_FLUSH:            INT2FIX(Z_NO_FLUSH)
     SYNC_FLUSH:          INT2FIX(Z_SYNC_FLUSH)
     FULL_FLUSH:          INT2FIX(Z_FULL_FLUSH)
     FINISH:              INT2FIX(Z_FINISH)
     OS_CODE:             INT2FIX(OS_CODE)
     OS_MSDOS:            INT2FIX(OS_MSDOS)
     OS_AMIGA:            INT2FIX(OS_AMIGA)
     OS_VMS:              INT2FIX(OS_VMS)
     OS_UNIX:             INT2FIX(OS_UNIX)
     OS_ATARI:            INT2FIX(OS_ATARI)
     OS_OS2:              INT2FIX(OS_OS2)
     OS_MACOS:            INT2FIX(OS_MACOS)
     OS_TOPS20:           INT2FIX(OS_TOPS20)
     OS_WIN32:            INT2FIX(OS_WIN32)
     OS_VMCMS:            INT2FIX(OS_VMCMS)
     OS_ZSYSTEM:          INT2FIX(OS_ZSYSTEM)
     OS_CPM:              INT2FIX(OS_CPM)
     OS_QDOS:             INT2FIX(OS_QDOS)
     OS_RISCOS:           INT2FIX(OS_RISCOS)
     OS_UNKNOWN:          INT2FIX(OS_UNKNOWN)


Class methods:
--------------
     adler32, crc32, crc_table, zlib_version

=end
module Zlib

  # ---------------------------------------------------------- Zlib::adler32
  #       Zlib.adler32(string, adler)
  # ------------------------------------------------------------------------
  #      Calculates Alder-32 checksum for +string+, and returns updated
  #      value of +adler+. If +string+ is omitted, it returns the Adler-32
  #      initial value. If +adler+ is omitted, it assumes that the initial
  #      value is given to +adler+.
  # 
  #      FIXME: expression.
  # 
  def self.adler32(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- Zlib::zlib_version
  #      Zlib::zlib_version()
  # ------------------------------------------------------------------------
  #      Returns the string which represents the version of zlib library.
  # 
  def self.version
  end

  # ----------------------------------------------------- Zlib::zlib_version
  #      Zlib::zlib_version()
  # ------------------------------------------------------------------------
  #      Returns the string which represents the version of zlib library.
  # 
  def self.zlib_version
  end

  # -------------------------------------------------------- Zlib::crc_table
  #      Zlib::crc_table()
  # ------------------------------------------------------------------------
  #      Returns the table for calculating CRC checksum as an array.
  # 
  def self.crc_table
  end

  # ------------------------------------------------------------ Zlib::crc32
  #       Zlib.crc32(string, adler)
  # ------------------------------------------------------------------------
  #      Calculates CRC checksum for +string+, and returns updated value of
  #      +crc+. If +string+ is omitted, it returns the CRC initial value. If
  #      +crc+ is omitted, it assumes that the initial value is given to
  #      +crc+.
  # 
  #      FIXME: expression.
  # 
  def self.crc32(arg0, arg1, *rest)
  end

end
