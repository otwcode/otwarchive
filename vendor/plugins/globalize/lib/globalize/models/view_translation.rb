module Globalize
  # Represents a view translation in the DB, which is a translation of a string
  # in the rails application itself. This includes error messages, controllers,
  # views, and flashes, but not database content.
  class ViewTranslation < Translation # :nodoc:

    def self.pick(key, language, idx, namespace = nil)
      conditions = 'tr_key = ? AND language_id = ? AND pluralization_index = ?'
      namespace_condition = namespace ? ' AND namespace = ?' : ' AND namespace IS NULL'
      conditions << namespace_condition
      find(:first, :conditions => [conditions,*[key, language.id, idx, namespace].compact])
    end

    #Find all namespaces used in translations
    def self.find_all_namespaces
      sql = <<-SQL
        SELECT distinct(namespace) FROM globalize_translations order by namespace
      SQL
      self.connection.select_values(sql).compact
    end

  end
end
