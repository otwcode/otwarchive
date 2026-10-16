module EmailCanonicalizer
  # Produces a canonical version of a given email reduced to its simplest form
  def self.canonicalize(email_to_clean)
    canonical_email = email_to_clean.downcase
    canonical_email.strip!
    canonical_email.sub!("@googlemail.com", "@gmail.com")

    # strip periods from gmail addresses
    if (matchdata = canonical_email.match(/(.+)@gmail\.com/))
      canonical_email = "#{matchdata[1].gsub('.', '')}@gmail.com"
    end

    # strip out anything after a +
    canonical_email.sub!(/(\+.*)(@.*$)/, '\2')

    canonical_email
  end
end
