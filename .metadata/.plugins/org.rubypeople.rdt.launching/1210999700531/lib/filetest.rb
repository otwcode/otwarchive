=begin
-------------------------------------------------------- Class: FileTest
     +FileTest+ implements file test operations similar to those used in
     +File::Stat+. It exists as a standalone module, and its methods are
     also insinuated into the +File+ class. (Note that this is not done
     by inclusion: the interpreter cheats).

------------------------------------------------------------------------


Instance methods:
-----------------
     blockdev?, chardev?, directory?, executable?, executable_real?,
     exist?, exists?, file?, grpowned?, identical?, owned?, pipe?,
     readable?, readable_real?, setgid?, setuid?, size, size?, socket?,
     sticky?, symlink?, writable?, writable_real?, zero?

=end
module FileTest

  def self.executable?(arg0)
  end

  def self.setuid?(arg0)
  end

  def self.readable?(arg0)
  end

  def self.symlink?(arg0)
  end

  def self.size?(arg0)
  end

  def self.size(arg0)
  end

  def self.identical?(arg0, arg1)
  end

  def self.writable_real?(arg0)
  end

  def self.zero?(arg0)
  end

  def self.chardev?(arg0)
  end

  def self.exists?(arg0)
  end

  def self.pipe?(arg0)
  end

  def self.file?(arg0)
  end

  def self.sticky?(arg0)
  end

  def self.writable?(arg0)
  end

  def self.blockdev?(arg0)
  end

  def self.exist?(arg0)
  end

  def self.grpowned?(arg0)
  end

  def self.executable_real?(arg0)
  end

  def self.setgid?(arg0)
  end

  def self.readable_real?(arg0)
  end

  def self.socket?(arg0)
  end

  def self.directory?(arg0)
  end

  def self.owned?(arg0)
  end

end
