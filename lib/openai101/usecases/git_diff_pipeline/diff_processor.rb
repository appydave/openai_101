# frozen_string_literal: true

module Openai101
  module Usecases
    module GitDiffPipeline
      class DiffProcessor
        attr_reader :json_structure

        def initialize
          @json_structure = []
        end

        def parse(file_diffs, file: nil)
          @json_structure = build_json_structure(file_diffs)

          save_to_file(file) if file
        end

        def load(file_path)
          return unless File.exist?(file_path)

          @json_structure = JSON.parse(File.read(file_path), symbolize_names: true)
        end

        def to_csv(file_path)
          save_csv_to_csv(file_path)
        end

        private

        # Builds the JSON structure from file diffs
        def build_json_structure(file_diffs)
          file_diffs.map do |file, diffs|
            {
              file: file, # Symbol key for file
              has_been_processed: false, # Symbol key for has_been_processed
              diffs: diffs.map.with_index(1) do |diff, index|
                {
                  index: index, # Symbol key for index
                  content: diff.strip, # Symbol key for content
                  is_pattern_match: false, # Symbol key for is_pattern_match
                  added_lines: diff.lines.count { |line| line.start_with?('+') }, # Symbol key for added_lines
                  removed_lines: diff.lines.count { |line| line.start_with?('-') }, # Symbol key for removed_lines
                  total_lines: diff.lines.count # Symbol key for total_lines
                }
              end
            }
          end
        end

        def save_to_file(file_path)
          File.write(file_path, JSON.pretty_generate(@json_structure)) if file_path
        end

        def save_csv_to_csv(file_path)
          CSV.open(file_path, 'w') do |csv|
            csv << %w[has_been_processed match_type file diff_index content is_pattern_match added_lines removed_lines total_lines]

            @json_structure.each do |file_data|
              file = file_data[:file]
              has_been_processed = file_data[:has_been_processed]
              match = ''

              file_data[:diffs].each do |diff|
                csv << [
                  has_been_processed,
                  match,
                  file,
                  diff[:index],
                  diff[:content].gsub("\n", '$CR$'), # Flatten content, replacing newlines with spaces for CSV readability
                  diff[:added_lines],
                  diff[:removed_lines],
                  diff[:total_lines]
                ]
              end
            end
          end
        end
      end
    end
  end
end
