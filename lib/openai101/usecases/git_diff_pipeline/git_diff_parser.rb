# frozen_string_literal: true

module Openai101
  module Usecases
    module GitDiffPipeline
      class GitDiffParser
        def split_diff(diff_content)
          files_with_diffs = {}
          current_file = nil
          current_diffs = []
          current_diff = ''

          diff_content.each_line do |line|
            if line.start_with?('diff --git')
              # Start of a new file's diff block, save previous diffs if there was one
              files_with_diffs[current_file] = current_diffs unless current_file.nil?

              # Extract the new filename
              current_file = line.split(' ')[2].sub('a/', '')
              current_diffs = []
              current_diff = ''
            elsif line.start_with?('@@')
              # If a new diff section starts, save the previous one
              current_diffs << current_diff unless current_diff.empty?
              current_diff = line
            elsif line.start_with?('+') || line.start_with?('-') || line.strip.empty?
              # Add lines of the diff block (including @@, +, -, or empty lines)
              current_diff += line
            end
          end

          # Add the last diff section to the current file's diff array
          current_diffs << current_diff unless current_diff.empty?

          # Save the last file's diffs
          files_with_diffs[current_file] = current_diffs unless current_file.nil?

          files_with_diffs
        end
      end
    end
  end
end
