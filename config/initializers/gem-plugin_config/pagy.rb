# frozen_string_literal: true

# https://ddnexus.github.io/pagy/docs/extras/i18n/
require "pagy/extras/i18n"

# See https://ddnexus.github.io/pagy/docs/api/pagy#variables
Pagy::DEFAULT[:limit] = ArchiveConfig.ITEMS_PER_PAGE
Pagy::DEFAULT[:size] = 9

Pagy::DEFAULT.freeze
