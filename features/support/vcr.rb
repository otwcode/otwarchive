require 'vcr'

VCR.config do |c|
  c.cassette_library_dir     = 'features/cassette_library'
  c.stub_with                :fakeweb
  c.ignore_localhost         = true
  #use this after setup...
  c.default_cassette_options = { :record => :none }
  #use this for setup...
  #c.default_cassette_options = { :record => :new_episodes }
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

  t.tags '@import_da'
  t.tags '@import_da_fic'

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

