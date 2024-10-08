# frozen_string_literal: true

module Openai101
  module Usecases
    module GitDiffPipeline
      class PromptBuilder
        PromptStruct = Struct.new(:header, :item, :footer)

        # Generates prompt files based on the provided filtered items
        def generate_prompts(output_dir:, items:, file_prefix:, prompt:, extension: 'txt', batch_size: 15, clear_output: false)
          FileUtils.mkdir_p(output_dir)

          clear_output_dir(output_dir) if clear_output

          # Group the diffs by file first to ensure they are grouped together
          grouped_items = group_items_by_file(items)

          # Process the grouped items while respecting the batch size limits
          process_in_batches(grouped_items, output_dir: output_dir, file_prefix: file_prefix, prompt: prompt, batch_size: batch_size, extension: extension)
        end

        private

        def clear_output_dir(output_dir)
          Dir.glob(File.join(output_dir, '*')).each { |f| File.delete(f) }
          puts "Cleared all existing files in the output directory: #{output_dir}"
        end

        # Group items by the file so that all diffs related to a file are grouped together
        def group_items_by_file(items)
          items.group_by { |item| item['file'] } # Group items by the 'file' key
        end

        # Process grouped items into batches and write them to files
        def process_in_batches(grouped_items, output_dir:, file_prefix:, prompt:, batch_size:, extension:)
          batch_content = String.new # Initialize as a mutable string
          current_batch_size = 0
          batch_number = 1

          grouped_items.each do |file_name, diffs|
            # If adding this file exceeds the batch size, write the current batch and start a new one
            if current_batch_size + diffs.size > batch_size && current_batch_size > 0
              # Add header and footer to the batch before writing
              batch_content = wrap_with_header_and_footer(batch_content, prompt)
              write_batch(output_dir, file_prefix, extension, batch_number, batch_content)
              batch_number += 1
              batch_content = String.new # Reset the batch content to a new mutable string
              current_batch_size = 0
            end

            # Add file name and diffs to the batch content
            batch_content << "File: #{file_name}\n"
            diffs.each do |diff|
              diff_content = format_diff(diff, prompt)
              batch_content << diff_content
            end

            current_batch_size += diffs.size
          end

          # Write the final batch if there are any remaining diffs
          return if batch_content.empty?

          batch_content = wrap_with_header_and_footer(batch_content, prompt)
          write_batch(output_dir, file_prefix, extension, batch_number, batch_content)
        end

        # Writes a batch of content to a file
        def write_batch(output_dir, file_prefix, extension, batch_number, content)
          batch_file_name = File.join(output_dir, "#{file_prefix}#{batch_number}.#{extension}")
          File.write(batch_file_name, content)
          puts "Created #{batch_file_name}"
        end

        # Formats the diff content for each diff using the provided prompt structure
        def format_diff(diff, prompt)
          # Duplication of prompt item before modification to avoid "frozen string" errors
          item_content = prompt.item.dup

          diff.each do |key, value|
            placeholder = "[#{key}]"
            # Replace placeholders with values in the prompt
            item_content.gsub!(placeholder, value.to_s) if item_content.include?(placeholder)
          end

          # Replace $CR$ with actual newlines
          item_content.gsub!('$CR$', "\n")

          item_content << "\n"
        end

        # Wrap batch content with the header and footer
        def wrap_with_header_and_footer(content, prompt)
          full_content = prompt.header.dup
          full_content << "\n" << content << "\n"
          full_content << prompt.footer
        end
      end
    end
  end
end
