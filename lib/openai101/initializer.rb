# frozen_string_literal: true

require 'dotenv'

Dotenv.load('.env')

OpenAI.configure do |config|
  tools_enabled = ENV.fetch('TOOLS_ENABLED', 'false')

  if tools_enabled == 'true'
    config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN')
    config.organization_id = ENV.fetch('OPENAI_ORGANIZATION_ID', nil)
    config.log_errors = true
  end

  puts "Initializing OpenAI with tools #{tools_enabled == 'true' ? 'enabled' : 'disabled'}"
end
