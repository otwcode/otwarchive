# For models which have pseuds (authors)
module Pseudable
  # This behaves very similarly to new_bylines=, but because it's designed to
  # be used for bulk editing works, it doesn't handle ambiguous pseuds well. So
  # we need to manually refine our guess as much as possible.
  def pseuds_to_add=(pseud_names)
    names = pseud_names.split(',').reject(&:blank?).map(&:strip)
    names.each do |name|
      possible_pseuds = Pseud.parse_byline(name)
      if possible_pseuds.size > 1
        possible_pseuds = Pseud.parse_byline(name, assume_matching_login: true)
      end
      pseud = possible_pseuds.first
      creatorships.find_or_initialize_by(pseud: pseud) if pseud
    end
  end
end
  
