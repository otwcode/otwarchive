# frozen_string_literal: true

module SkinFileHelper
  SITE_SKIN_PATH = 'stylesheets/site/'
  SKIN_PATH = 'stylesheets/skins/'

  def site_skins_dir_simple
    Rails.public_path.join(SITE_SKIN_PATH).to_s
  end

  def naturalized(string)
    string.scan(/[^\d]+|[\d]+/).map { |f| f =~ /\d+(\.\d+)?/ ? f.to_f : f }
  end

  # Get the most recent version and find the topmost skin
  def current_version
    skin_dir_entries(site_skins_dir_simple, /^\d+\.\d+$/).last
  end

  def skins_dir
    Rails.public_path.join(SKIN_PATH).to_s
  end

  def skin_dir_entries(dir, regex)
    Dir.entries(dir).select { |f| f.match(regex) }
       .sort_by { |f| naturalized(f.to_s) }
  end
end
