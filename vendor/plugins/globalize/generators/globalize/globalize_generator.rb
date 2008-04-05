require 'zlib'
require 'pathname'

class GlobalizeGenerator < MigrationGenerator

  attr_accessor :attributes_for_migrations

  def initialize(runtime_args, runtime_options = {})
    arg = runtime_args.shift
    @internal,@tiny = false,false
    case arg.downcase
      when 'tiny'
        @tiny = true
      when 'internal'
        @attributes_for_migrations = generate_translated_model_migrations(runtime_args.pop)
        raise %q(No models found using internal storage mechanism or all required columns exist in db.) and return if @attributes_for_migrations.empty?
        @internal = true
        @migration_file_name = "globalize_add_translated_fields_for_#{@attributes_for_migrations.keys.collect {|key| key.split('/').first.underscore}.join('_')}"
        @migration_class_name = "GlobalizeAddTranslatedFieldsFor#{@attributes_for_migrations.keys.collect {|key| key.split('/').first}.join}"
      else
        @tiny = false
    end if arg

    super([ "globalize_migration" ] + runtime_args, runtime_options)
  end

  def banner
    %q(
    Usage: script/generate globalize [tiny|internal] [lang|lang1,lang2...]
    No arguments generates a migration for the globalize tables with all the data files (major languages only).
    Specify "tiny" to generate a compact version of the data files (major languages only).
    Specify "internal" to generate a migration of all model attributes marked as translatable (when keep_translations_in_model is true.)
    )
  end

  def inflate_schema
    deflated_name = @tiny ? 'tiny_migration.rb.gz' : 'migration.rb.gz'
    inflated_path = source_path('migration.rb')
    deflated_path = source_path(deflated_name)

    return if File.exist?(inflated_path) && !File.exist?(deflated_path)
    return if !File.exist?(deflated_path)

    File.open(inflated_path, 'w') do |f|
      Zlib::GzipReader.open(deflated_path) do |gzip|
        gzip.each do |line|
          line.chomp!
          f.puts line
        end
      end
    end
  end

=begin
  For each supplied langugage finds all attributes (in all models) marked as
  translatable and creates a hash like:

    {'ModelClassName' => [['attribute_es','string', nil], ['attribute_fr','string', nil]]}

   where the value is an array whose entries are (in order):

   * {attribute_name}_{lang_suffix},
   * {attribute_column_type}
   * {attribute_default_value}
=end
  def generate_translated_model_migrations(langs)
    require "#{RAILS_ROOT}/config/environment"
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    langs = langs ? langs.split(',') : []

    raise %q(You must specify at least one non-base language as an extra argument.
    You may also specify a comma-separated list of as many non-base languages as you need.

    e.g. script/generate globalize model es,en,fr) if langs.empty?

    attributes_for_migrations = {}

    Dir.glob("#{RAILS_ROOT}/app/models/*.rb").each  do |f|
      model = File.basename(f).gsub(File.extname(f),'').camelize.constantize rescue nil
      if model && model.respond_to?(:base_class) && model.base_class.superclass == ActiveRecord::Base
        if model.keep_translations_in_model || Globalize::DbTranslate.keep_translations_in_model
        key = "#{model.name}/#{model.table_name}"
        attributes_for_migrations[key] = []
          langs.each do |lang|
            model.globalize_facets.each do |facet|
              localized_facet_name = "#{facet}_#{lang}"
              unless (column = model.columns.find {|c| c.name == facet.to_s}) && model.column_names.include?(localized_facet_name)
                attributes_for_migrations[key] << [localized_facet_name, column.type, column.default]
              end
            end
          end
        end
      end
    end

    attributes_for_migrations
  end

  def manifest
    record do |m|
      m.directory 'db/migrate'
      m.inflate_schema unless @internal
      m.migration_template 'migration.rb', 'db/migrate' unless @internal
      m.migration_template 'model_migration.rb', 'db/migrate', :migration_file_name => @migration_file_name,
                                                               :assigns => {
                                                                  :attributes_for_migrations => @attributes_for_migrations,
                                                                  :migration_class_name => @migration_class_name
                                                               } if @internal
    end
  end
end