# This class will reindex all existing old indexes to the new version of
# elasticsearch
#
# ES UPGRADE TRANSITION #
# Remove class
class ElasticsearchUpgradeReindexer

  OLD_VERSION_URL = 'http://127.0.0.1:9201'

  def recreate_indices
    existing_indices = JSON.parse($elasticsearch.indices.get_mapping.to_json)

    existing_indices.each do |index|
      name = 0
      mappings = 1

      next if $new_elasticsearch.indices.exists(index: index[name])

      settings = get_settings(index[name])
      mappings = get_mappings(index[mappings])

      $new_elasticsearch.indices.create(
        index: index[name],
        body: {
          settings: settings,
          mappings: mappings
        }
      )
    end
  end

  def reindex_from_remote
    $new_elasticsearch.indices.get_mapping.keys.each do |index|
      request_body = {
        source: {
          remote: {
            host: OLD_VERSION_URL
          },
          index: index
        },
        dest: {
          index: index
        }
      }

      $new_elasticsearch.reindex(body: request_body)
    end
  end

  def get_settings(index)
    request = JSON.parse($elasticsearch.perform_request('GET', "#{index}/_settings").to_json)
    settings = request["body"][index]["settings"]

    settings.delete("index.version.created") && settings.delete("index.uuid")

    settings
  end

  def get_mappings(index)
    make_mappings_compatible_with_new_es(index)
  end

  def make_mappings_compatible_with_new_es(mappings)
    new_mappings = mappings.dup

    new_mappings.each do |type, type_properties|
      properties = type_properties["properties"]

      properties.keys.each do |key|

        if properties[key] && properties[key]["type"] == "string"
          properties[key]["type"] = "text"
        end

        if properties[key] == "string"
          properties[key] = "text"
        end

      end
    end

    new_mappings
  end

end
