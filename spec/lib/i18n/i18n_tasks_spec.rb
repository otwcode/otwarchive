require "i18n/tasks"
require "support/i18n_newlines_tasks"

describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys(locales: ["en"], types: [:used, :plural]) }
  let(:unused_keys) { i18n.unused_keys(locales: ["en"]) }
  let(:newlines) { i18n.extend(I18nNewlinesTasks).newlines(locales: ["en"]) }

  it "en does not have missing keys" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing -l en -t used,plural' to show them"
  end

  it "en does not have unused keys" do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused -l en' to show them"
  end

  it "en files are normalized" do
    non_normalized = i18n.non_normalized_paths.select { |path| path.end_with?("en.yml") }
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize -l en' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  # We want to keep formatting out of I18n-ized strings, and one paragraph per key.
  it "en does not have values with newlines" do
    error_message = "The following locale keys have values that contain newlines:\n" \
                    "#{newlines.key_names(root: true)}"
    expect(newlines).to be_empty, error_message
  end
end
