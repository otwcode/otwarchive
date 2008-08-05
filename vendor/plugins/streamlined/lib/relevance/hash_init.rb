module HashInit
  # Initalize an object with a hash of key values to be set on self,
  # and optionally yield self to set things in a block if desired.
  def initialize(hash={})
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end if hash
    yield(self) if block_given?
  end
end