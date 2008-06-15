=begin
------------------------------------------------------- Class: FileUtils

FILEUTILS.RB
============
     Copyright (c) 2000-2006 Minero Aoki

     This program is free software. You can distribute/modify this
     program under the same terms of ruby.


module FileUtils
----------------
     Namespace for several file utility methods for copying, moving,
     removing, etc.

     Module Functions
       cd(dir, options)
       cd(dir, options) {|dir| .... }
       pwd()
       mkdir(dir, options)
       mkdir(list, options)
       mkdir_p(dir, options)
       mkdir_p(list, options)
       rmdir(dir, options)
       rmdir(list, options)
       ln(old, new, options)
       ln(list, destdir, options)
       ln_s(old, new, options)
       ln_s(list, destdir, options)
       ln_sf(src, dest, options)
       cp(src, dest, options)
       cp(list, dir, options)
       cp_r(src, dest, options)
       cp_r(list, dir, options)
       mv(src, dest, options)
       mv(list, dir, options)
       rm(list, options)
       rm_r(list, options)
       rm_rf(list, options)
       install(src, dest, mode = <src's>, options)
       chmod(mode, list, options)
       chmod_R(mode, list, options)
       chown(user, group, list, options)
       chown_R(user, group, list, options)
       touch(list, options)

     The +options+ parameter is a hash of options, taken from the list
     +:force+, +:noop+, +:preserve+, and +:verbose+. +:noop+ means that
     no changes are made. The other two are obvious. Each method
     documents the options that it honours.

     All methods that have the concept of a "source" file or directory
     can take either one file or a list of files in that argument. See
     the method documentation for examples.

     There are some `low level' methods, which do not accept any option:

       copy_entry(src, dest, preserve = false, dereference = false)
       copy_file(src, dest, preserve = false, dereference = true)
       copy_stream(srcstream, deststream)
       remove_entry(path, force = false)
       remove_entry_secure(path, force = false)
       remove_file(path, force = false)
       compare_file(path_a, path_b)
       compare_stream(stream_a, stream_b)
       uptodate?(file, cmp_list)


module FileUtils::Verbose
-------------------------
     This module has all methods of FileUtils module, but it outputs
     messages before acting. This equates to passing the +:verbose+ flag
     to methods in FileUtils.


module FileUtils::NoWrite
-------------------------
     This module has all methods of FileUtils module, but never changes
     files/directories. This equates to passing the +:noop+ flag to
     methods in FileUtils.


module FileUtils::DryRun
------------------------
     This module has all methods of FileUtils module, but never changes
     files/directories. This equates to passing the +:noop+ and
     +:verbose+ flags to methods in FileUtils.

------------------------------------------------------------------------
     ###################################################################
     ######## This a FileUtils extension that defines several additional
     commands to be added to the FileUtils utility functions.

------------------------------------------------------------------------


Includes:
---------
     StreamUtils_


Constants:
----------
     LN_SUPPORTED: [true]
     METHODS:      singleton_methods() - %w( private_module_function    
                     commands options have_option? options_of
                   collect_method )
     RUBY:         File.join(Config::CONFIG['bindir'],
                   Config::CONFIG['ruby_install_name'])


Class methods:
--------------
     collect_method, commands, have_option?, options, options_of


Instance methods:
-----------------
     cd, chdir, chmod, chmod_R, chown, chown_R, cmp, compare_file,
     compare_stream, copy, copy_entry, copy_file, copy_stream, cp, cp_r,
     fu_have_symlink?, fu_world_writable?, getwd, identical?, install,
     link, ln, ln_s, ln_sf, makedirs, mkdir, mkdir_p, mkpath, move, mv,
     pwd, remove, remove_dir, remove_entry, remove_entry_secure,
     remove_file, rm, rm_f, rm_r, rm_rf, rmdir, rmtree, ruby, safe_ln,
     safe_unlink, sh, split_all, symlink, touch, uptodate?

=end
module FileUtils
  include FileUtils::StreamUtils_

  def self.mkdir(arg0, arg1, arg2, *rest)
  end

  def self.mkdir_p(arg0, arg1, arg2, *rest)
  end

  def self.copy(arg0, arg1, arg2, arg3, *rest)
  end

  def self.remove_entry_secure(arg0, arg1, arg2, *rest)
  end

  def self.remove_file(arg0, arg1, arg2, *rest)
  end

  def self.chdir(arg0, arg1, arg2, *rest)
  end

  def self.mkpath(arg0, arg1, arg2, *rest)
  end

  def self.symlink(arg0, arg1, arg2, arg3, *rest)
  end

  def self.cp_r(arg0, arg1, arg2, arg3, *rest)
  end

  def self.rm_rf(arg0, arg1, arg2, *rest)
  end

  def self.cp(arg0, arg1, arg2, arg3, *rest)
  end

  def self.remove(arg0, arg1, arg2, *rest)
  end

  def self.identical?(arg0, arg1)
  end

  def self.chmod_R(arg0, arg1, arg2, arg3, *rest)
  end

  def self.chown(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  def self.copy_entry(arg0, arg1, arg2, arg3, *rest)
  end

  def self.touch(arg0, arg1, arg2, *rest)
  end

  # ---------------------------------------------- FileUtils::collect_method
  #      FileUtils::collect_method(opt)
  # ------------------------------------------------------------------------
  #      Returns an Array of method names which have the option +opt+.
  # 
  #        p FileUtils.collect_method(:preserve) #=> ["cp", "cp_r", "copy", "install"]
  # 
  def self.collect_method(arg0)
  end

  def self.private_module_function(arg0)
  end

  def self.link(arg0, arg1, arg2, arg3, *rest)
  end

  def self.copy_file(arg0, arg1, arg2, arg3, *rest)
  end

  def self.rm_r(arg0, arg1, arg2, *rest)
  end

  def self.compare_file(arg0, arg1)
  end

  def self.chown_R(arg0, arg1, arg2, arg3, arg4, *rest)
  end

  def self.ln_sf(arg0, arg1, arg2, arg3, *rest)
  end

  def self.rm(arg0, arg1, arg2, *rest)
  end

  def self.install(arg0, arg1, arg2, arg3, *rest)
  end

  def self.chmod(arg0, arg1, arg2, arg3, *rest)
  end

  def self.pwd
  end

  def self.uptodate?(arg0, arg1, arg2, arg3, *rest)
  end

  def self.compare_stream(arg0, arg1)
  end

  # -------------------------------------------------- FileUtils::options_of
  #      FileUtils::options_of(mid)
  # ------------------------------------------------------------------------
  #      Returns an Array of option names of the method +mid+.
  # 
  #        p FileUtils.options(:rm)  #=> ["noop", "verbose", "force"]
  # 
  def self.options_of(arg0)
  end

  def self.ln(arg0, arg1, arg2, arg3, *rest)
  end

  def self.copy_stream(arg0, arg1)
  end

  def self.move(arg0, arg1, arg2, arg3, *rest)
  end

  def self.safe_unlink(arg0, arg1, arg2, *rest)
  end

  def self.remove_dir(arg0, arg1, arg2, *rest)
  end

  # ---------------------------------------------------- FileUtils::commands
  #      FileUtils::commands()
  # ------------------------------------------------------------------------
  #      Returns an Array of method names which have any options.
  # 
  #        p FileUtils.commands  #=> ["chmod", "cp", "cp_r", "install", ...]
  # 
  def self.commands
  end

  # ----------------------------------------------------- FileUtils::options
  #      FileUtils::options()
  # ------------------------------------------------------------------------
  #      Returns an Array of option names.
  # 
  #        p FileUtils.options  #=> ["noop", "force", "verbose", "preserve", "mode"]
  # 
  def self.options
  end

  def self.rmdir(arg0, arg1, arg2, *rest)
  end

  def self.ln_s(arg0, arg1, arg2, arg3, *rest)
  end

  def self.remove_entry(arg0, arg1, arg2, *rest)
  end

  def self.cmp(arg0, arg1)
  end

  def self.getwd
  end

  def self.cd(arg0, arg1, arg2, *rest)
  end

  def self.makedirs(arg0, arg1, arg2, *rest)
  end

  def self.mv(arg0, arg1, arg2, arg3, *rest)
  end

  def self.rmtree(arg0, arg1, arg2, *rest)
  end

  def self.rm_f(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------ FileUtils::have_option?
  #      FileUtils::have_option?(mid, opt)
  # ------------------------------------------------------------------------
  #      Returns true if the method +mid+ have an option +opt+.
  # 
  #        p FileUtils.have_option?(:cp, :noop)     #=> true
  #        p FileUtils.have_option?(:rm, :force)    #=> true
  #        p FileUtils.have_option?(:rm, :perserve) #=> false
  # 
  def self.have_option?(arg0, arg1)
  end

end
