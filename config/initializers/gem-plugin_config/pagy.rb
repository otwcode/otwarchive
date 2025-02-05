# frozen_string_literal: true

Pagy::DEFAULT[:limit] = ArchiveConfig.ITEMS_PER_PAGE

Pagy::DEFAULT.freeze
