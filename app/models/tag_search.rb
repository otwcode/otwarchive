# ES UPGRADE TRANSITION #
# Remove class
class TagSearch < Search

  def self.search(options={})
    query_string = self.new.escape_slashes(options[:name] || '')
    response = Tag.tire.search(page: options[:page], per_page: 50, type: nil, load: false) do
      query do
        boolean do
          must { string query_string, default_operator: "AND" } if query_string.present?
          must { term :canonical, 'T' } if options[:canonical].present?

          if options[:type].present?
            # To support the tags indexed prior to IndexSubqueue, we want to
            # find the type either in the tag_type field or the _type field:
            should { term '_type', options[:type].downcase }
            should { term :tag_type, options[:type].downcase }

            # The tire gem doesn't natively support :minimum_should_match,
            # but elasticsearch 0.90 does, so we hack it in.
            @value[:minimum_should_match] = 1
          end
        end
      end
    end
    SearchResult.new('Tag', response)
  end

end
