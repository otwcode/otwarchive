module PaginationHelper
  include Pagy::Frontend

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options = collection_or_options
      collection_or_options = nil
    end
    options = options.merge renderer: PaginationListLinkRenderer unless options[:renderer]
    super(*[collection_or_options, options].compact)
  end

  # Cf https://github.com/ddnexus/pagy/blob/master/gem/lib/pagy/frontend.rb
  # i18n-tasks-use t("pagy.prev")
  # i18n-tasks-use t("pagy.next")
  # i18n-tasks-use t("pagy.aria_label.nav")
  def pagy_nav(pagy, id: nil, aria_label: nil, **vars)
    return nil unless pagy

    # Keep will_paginate behavior of showing nothing if only one page
    return nil if pagy.series.length <= 1

    id = %( id="#{id}") if id
    a  = pagy_anchor(pagy, **vars)

    html = %(<h4 class="landmark heading">#{t('a11y.navigation')}</h4>)

    html << %(<ol#{id} class="pagination actions pagy" role="navigation" #{nav_aria_label(pagy, aria_label: aria_label)}>)

    prev_text = pagy_t("pagy.prev")
    prev_a =
      if (p_prev = pagy.prev)
        a.call(p_prev, prev_text)
      else
        %(<span class="disabled">#{prev_text}</span>)
      end
    html << %(<li class="previous">#{prev_a}</li>)

    pagy.series(**vars).each do |item| # series example: [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
      html << %(<li>)
      html << case item
              when Integer
                a.call(item)
              when String
                %(<a role="link" aria-disabled="true" aria-current="page" class="current">#{pagy.label_for(item)}</a>)
              when :gap
                %(<span class="gap">#{pagy_t('pagy.gap')}</span>)
              else
                raise InternalError, "expected item types in series to be Integer, String or :gap; got #{item.inspect}"
              end
      html << %(</li>)
    end

    next_text = pagy_t("pagy.next")
    next_a =
      if (p_next = pagy.next)
        a.call(p_next, next_text)
      else
        %(<span class="disabled">#{next_text}</span>)
      end
    html << %(<li class="next">#{next_a}</li>)

    html << %(</ol>)
  end
end
