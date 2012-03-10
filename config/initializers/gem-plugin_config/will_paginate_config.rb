require 'will_paginate/array'
WillPaginate.per_page = ArchiveConfig.ITEMS_PER_PAGE

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options, collection = collection, nil if collection.is_a? Hash
      collection ||= infer_collection_from_controller

      options = options.symbolize_keys
      options[:renderer] = PaginationListLinkRenderer

      super(collection, options).try(:html_safe)
    end
  end
end
