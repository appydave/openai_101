# frozen_string_literal: true

module Openai101
  module Usecases
    module GitDiffPipeline
      class DiffReport
        def initialize(csv_data)
          @csv_data = csv_data
        end

        # Main function to generate the full report with match type codes and processed files
        def generate_report
          match_types = gather_match_types

          # Step 1: Generate the match type code table
          match_type_table = generate_match_type_table(match_types)

          # Step 2: Generate the file processing table using match type codes
          file_column_width = @csv_data.map { |row| row['file'].length }.max
          file_column_width = [file_column_width, 'File'.length].max # Ensure it's at least as long as 'File'
          file_table = generate_file_table(match_types, file_column_width)

          # Calculate the length of the separator line (including the pipe symbols)
          separator_length = file_column_width + 2 + 9 + (match_types.length * 5) + ((match_types.length - 1) * 3) + 2
          separator_line = '-' * separator_length

          # Combine the tables: match type table, file table, and repeat match type table at the bottom
          match_type_table + "\n" + separator_line + "\n" + file_table + "\n" + separator_line + "\n" + match_type_table
        end

        def save_report(file_path)
          report = generate_report
          File.write(file_path, report)
        end

        def print_report
          puts generate_report
        end

        private

        # Gather all unique match types from the CSV data
        def gather_match_types
          @csv_data.flat_map { |row| row['match_type'].split }.uniq.sort
        end

        # Generate the table that assigns a letter code to each match type
        def generate_match_type_table(match_types)
          header = "| Code | Match Type               |\n"
          separator = "|------|--------------------------|\n"
          rows = match_types.each_with_index.map do |type, index|
            code = ('A'.ord + index).chr # Assigning letters A, B, C, etc.
            "|  #{code}   | #{type.ljust(25)} |\n"
          end
          header + separator + rows.join
        end

        # Generate the main report table with processed file data
        def generate_file_table(match_types, file_column_width)
          count_column_width = 3 # Support for two-digit numbers with padding
          match_type_header = match_types.map.with_index { |_, i| ('A'.ord + i).chr.ljust(3) }.join(' | ')

          header = "| #{'File'.ljust(file_column_width)} | Processed | #{match_type_header} |\n"
          separator = "|#{'-' * (file_column_width + 2)}|-----------|#{match_types.map { '-' * 5 }.join('|')}|\n"

          # Group the CSV data by file and aggregate match counts
          file_data = @csv_data.group_by { |row| row['file'] }

          rows = file_data.map do |file, rows|
            processed = rows.any? { |row| row['has_been_processed'] == 'true' } ? 'Yes' : 'No'
            file_name = file.ljust(file_column_width)

            # Count occurrences of each match type for the file
            match_counts = match_types.map do |type|
              count = rows.count { |row| row['match_type'].include?(type) }
              count > 0 ? count.to_s.rjust(3) : ' ' * 3
            end

            "| #{file_name} | #{processed.ljust(9)} | #{match_counts.join(' | ')} |\n"
          end

          header + separator + rows.join
        end
      end
    end
  end
end
