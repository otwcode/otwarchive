class PseudSearch < Search
  
  def self.search(options={})
    query_string = self.new.escape_slashes(options[:query] || '')
    response = Pseud.tire.search(page: options[:page], per_page: 50, type: nil, load: false) do
      query do
        boolean do
          must { string query_string, default_operator: "AND" } if query_string.present?
          must { term :collection_ids, options[:collection_id] } if options[:collection_id].present?
        end
      end
    end
    SearchResult.new('Pseud', response)
  end
  
end