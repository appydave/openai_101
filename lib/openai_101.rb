# frozen_string_literal: true

require 'openai'

require 'base64'
require 'clipboard'
require 'csv'
require 'damerau-levenshtein'
require 'json'
require 'table_print'
require 'pry'
require 'active_model'

require 'openai101/version'
require 'openai101/initializer'
require 'openai101/types/hash_type'
require 'openai101/types/array_type'
require 'openai101/types/base_model'

require 'openai101/models/completion_params'

require 'openai101/usecases/git_diff_pipeline/git_diff_parser'
require 'openai101/usecases/git_diff_pipeline/diff_processor'
require 'openai101/usecases/git_diff_pipeline/diff_report'
require 'openai101/usecases/git_diff_pipeline/prompt_matcher'
require 'openai101/usecases/git_diff_pipeline/match_processor'
require 'openai101/usecases/git_diff_pipeline/prompt_builder'

module Openai101
  # raise Openai101::Error, 'Sample message'
  Error = Class.new(StandardError)
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'Openai101::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('openai_101/version') }
  version   = Openai101::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
