module Recording
  def self.stderr
    $stderr = recorder = StringIO.new
    begin
      yield
    ensure
      $stderr = STDERR
    end
    recorder.rewind
    recorder.read
  end
end
