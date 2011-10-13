# Make will_paginate use our link renderer instead of the default
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'PaginationListLinkRenderer'
