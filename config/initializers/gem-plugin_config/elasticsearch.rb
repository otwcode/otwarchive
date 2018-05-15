# ES UPGRADE TRANSITION #
# Remove $new_elasticsearch definition, since ELASTICSEARCH_1_URL should point
# to new ES instance
$elasticsearch = Elasticsearch::Client.new host: ArchiveConfig.ELASTICSEARCH_1_URL
$new_elasticsearch = Elasticsearch::Client.new host: ArchiveConfig.UPGRADED_ELASTICSEARCH_URL
