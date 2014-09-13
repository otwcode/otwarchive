module ES
  class PseudIndexer < ES::Indexer

    def self.klass
      'Pseud'
    end

    def self.mapping
    end

    def document(object)
    end
  end
end