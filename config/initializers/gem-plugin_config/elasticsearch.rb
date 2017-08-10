$elasticsearch = Elasticsearch::Client.new host: ArchiveConfig.ELASTICSEARCH_1_URL
$new_elasticsearch = Elasticsearch::Client.new host: ArchiveConfig.UPGRADED_ELASTICSEARCH_URL
