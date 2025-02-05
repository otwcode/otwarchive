# frozen_string_literal: true

# See https://ddnexus.github.io/pagy/docs/api/pagy#variables
Pagy::DEFAULT[:limit] = ArchiveConfig.ITEMS_PER_PAGE
Pagy::DEFAULT[:size] = 9

Pagy::DEFAULT.freeze
