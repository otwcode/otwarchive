class ElasticsearchSimpleClient

  # include HTTParty

  # base_uri { elasticsearch_url }

  def self.send_batch(batch_data)
    data = batch_data.join("\n") + "\n"
    elasticsearch.perform_request("POST", "/_bulk", body: data)
  end

  def self.perform_count(index, type, query)
    elasticsearch.perform_request("GET", "/#{index}/#{type}/_count", body: query.to_json)
  end

  def self.elasticsearch
    if User.current_user && $rollout.active?(:use_new_search, User.current_user)
      $new_elasticsearch
    else
      $elasticsearch
    end
  end

end
