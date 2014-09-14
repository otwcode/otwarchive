module ES
  class PseudIndexer < ES::Indexer

    def self.klass
      'Pseud'
    end

    def self.mapping
      {
        'pseud' => {
          properties: {
            name: {
              type: 'string',
              analyzer: 'simple'
            },
            user_login: {
              type: 'string',
              analyzer: 'simple'
            }
          }
        }
      }
    end

    def document(object)
      object.as_json(
        root: false,
        only: [:id, :user_id, :name, :description],
        methods: [:user_login]
      )
    end
  end
end