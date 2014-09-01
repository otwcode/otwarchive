class ElasticsearchSimpleClient

  include HTTParty

  base_uri ArchiveConfig.ELASTICSEARCH_URL

  def self.send_batch(batch_data)
    data = batch_data.join("\n") + "\n"
    self.post("/_bulk", body: data)
  end

end