# frozen_string_literal: true

module Openai101
  module Usecases
    module GitDiffPipeline
      class MatchProcessor
        attr_reader :data
        attr_accessor :csv_file_path

        def initialize(csv_file_path: nil)
          @data = []
          load_csv(csv_file_path) if csv_file_path
        end

        def process(limit: nil, progressive_save: false, &pattern_matcher)
          processed_count = 0

          @data.each do |row|
            next if row['has_been_processed'] == 'true' # Skip already processed rows

            row['match_type'] = pattern_matcher.call(row)
            row['has_been_processed'] = 'true'
            processed_count += 1

            puts '.'

            save_csv(csv_file_path) if progressive_save

            break if limit && processed_count >= limit
          end
        end

        def load_csv(csv_file_path)
          @csv_file_path = csv_file_path
          @data = CSV.read(csv_file_path, headers: true).map(&:to_h)
        end

        def save_csv(csv_file_path)
          CSV.open(csv_file_path, 'w') do |csv|
            csv << @data.first.keys # Write headers
            @data.each do |row|
              csv << row.values
            end
          end
        end
      end
    end
  end
end
