begin
  if ThinkingSphinx.respond_to?("suppress_delta_output=")
    ThinkingSphinx.suppress_delta_output=true 
  end
rescue NameError
end

