class OpenStruct
  alias_method :to_hash, :marshal_dump
end