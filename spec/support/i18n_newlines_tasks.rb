module I18nNewlinesTasks
  def newlines(locales: nil)
    locales ||= self.locales
    forest = empty_forest

    locales.each do |locale|
      forest.merge!(data[locale].select_keys do |key, node|
        next if ignore_key?(key, :newlines)

        node.value.is_a?(String) && node.value.include?("\n")
      end)
    end

    forest
  end
end
