# frozen_string_literal: true

# This comes from GitLab's Rubocop setup
# Auto-require all cops under `rubocop/cop/**/*.rb`
Dir[File.join(__dir__, "cop", "**", "*.rb")].each { |file| require file }
