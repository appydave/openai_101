# frozen_string_literal: true

require 'pry'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start

require 'openai_101'

support_glob = File.join(__dir__, 'support', '**', '*.rb')

Dir[support_glob].sort.each { |file| require file }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.filter_run_when_matching :focus

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # I enable tools during course development, this is not turned on in CI
  config.filter_run_excluding :tools_enabled unless ENV['TOOLS_ENABLED'] == 'true'

  Dir[support_glob].each do |file|
    module_name = File.basename(file, '.rb').split('_').collect(&:capitalize).join
    config.include Object.const_get(module_name)
  end
end
