class PseudIndexer < Indexer

  def self.klass
    "Pseud"
  end

  def self.mapping
    {
      "pseud" => {
        properties: {
          name: {
            type: "text",
            analyzer: "simple"
          },
          user_login: {
            type: "text",
            analyzer: "simple"
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [:id, :user_id, :name, :description, :created_at],
      methods: [:user_login]
    )
  end
end
