require 'vcr'

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir     = 'features/cassette_library'
  c.hook_into                :typhoeus
  c.allow_http_connections_when_no_cassette = true

  #use this after setup...
  # Cassettes are now deleted and re-recorded after 30 days. This will ensure
  # that LJ/DW/DA don't update their HTML and break our story parser without us
  # knowing about it.
  c.default_cassette_options = { :record => :none, :re_record_interval => 30.days }
  #use this for setup...
  #c.default_cassette_options = { :record => :new_episodes, :re_record_interval => 30.days }
end

VCR.cucumber_tags do |t|
  t.tags '@archivist_import'
  t.tags '@bookmark_fandom_error'
  t.tags '@bookmark_url_error'

  t.tags '@work_import_minimal_valid'
  t.tags '@work_import_tags'
  t.tags '@work_import_multi_tags_backdate'
  t.tags '@work_import_special_characters_auto_utf'
  t.tags '@work_import_special_characters_auto_latin', :record => :all
  t.tags '@work_import_special_characters_man_latin', :record => :all
  t.tags '@work_import_special_characters_man_cp', :record => :all
  t.tags '@work_import_special_characters_man_utf'
  t.tags '@work_import_nul_character'
  t.tags '@work_import_errors', :record => :all # need to run this every time bc the url is a bogus one (on purpose, for testing) so it's never properly "recorded"

  # need to run this every time for the devart features, because the recorded responses run into an encoding error I don't have time to investigate
  t.tags '@import_da_title_link', :record => :all
  # t.tags '@import_da_gallery_link', :record => :all # TODO: uncomment if/when implementing this feature
  t.tags '@import_da_fic', :record => :all

  t.tags '@import_dw'
  t.tags '@import_dw_tables'
  t.tags '@import_dw_tables_no_backdate'
  t.tags '@import_dw_comm'
  t.tags '@import_dw_multi_chapter'

  t.tags '@import_ffn'
  t.tags '@import_ffn_multi_chapter'

  t.tags '@import_lj'
  t.tags '@import_lj_tables'
  t.tags '@import_lj_no_backdate'
  t.tags '@import_lj_comm', :record => :all
  t.tags '@import_lj_multi_chapter'
  t.tags '@import_lj_underscores'

  t.tags '@import_yt'
  t.tags '@import_yt_no_notes'
  t.tags '@import_yt_ny'

  t.tags '@work_external_parent'
  t.tags '@work_external_language'
end

