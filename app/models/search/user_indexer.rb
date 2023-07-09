class UserIndexer < Indexer
  def self.klass
    "User"
  end

  def self.klass_with_includes
    User.includes(:pseuds, :roles, :audits)
  end

  def self.mapping
    {
      properties: {
        login: {
          type: "keyword",
          normalizer: "keyword_normalizer"
        },
        email: {
          type: "keyword",
          normalizer: "keyword_normalizer"
        },
        names: {
          type: "keyword",
          normalizer: "keyword_normalizer"
        },
        all_names: {
          type: "keyword",
          normalizer: "keyword_normalizer"
        },
        all_emails: {
          type: "keyword",
          normalizer: "keyword_normalizer"
        }
      }
    }
  end

  def self.settings
    {
      analysis: {
        normalizer: {
          keyword_normalizer: {
            type: "custom",
            filter: ["lowercase", "asciifolding"]
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [:id, :login, :email, :created_at],
      methods: [:role_ids]
    ).merge(extra_info(object))
  end

  def extra_info(object)
    names = ([object.login] + object.pseuds.map(&:name)).uniq
    past_names = object.historic_values("login")
    past_emails = object.historic_values("email")

    {
      active: object.active?,
      names: names,
      all_names: (names + past_names).uniq,
      all_emails: ([object.email] + past_emails).uniq
    }
  end
end
