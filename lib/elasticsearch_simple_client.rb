class ElasticsearchSimpleClient

  include HTTParty

  base_uri ArchiveConfig.ELASTICSEARCH_URL

  def self.send_batch(batch_data)
    data = batch_data.join("\n") + "\n"
    self.post("/_bulk", body: data)
  end

  def self.perform_count(index, type, query)
    self.get("/#{index}/#{type}/_count", body: query.to_json)
  end

end