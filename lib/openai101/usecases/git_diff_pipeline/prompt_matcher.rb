module Openai101
  module Usecases
    module GitDiffPipeline
      class PromptMatcher
        attr_reader :prompt, :expected_values, :default_value

        # Initialize the matcher with a prompt, expected values, and a default value if no match is found
        def initialize(prompt:, expected_values:, default_value:)
          @prompt = prompt # The prompt with placeholders
          @expected_values = expected_values # The set of expected values (e.g., ['HASH_SHORTHAND_SYNTAX', 'NO_MATCH'])
          @default_value = default_value # The default value if no match is found (e.g., 'NO_MATCH')
        end

        def call(row)
          # Dynamically fill the prompt with values from the row
          filled_prompt = merge_row_into_prompt(row)

          response = OpenAI::Client.new.chat(
            parameters: {
              model: 'gpt-4o-mini',
              messages: [{ role: 'user', content: filled_prompt }],
              temperature: 0.7
            }
          )

          value = response.dig('choices', 0, 'message', 'content').strip

          if @expected_values.include?(value)
            puts value
            value
          else
            @default_value
          end
        end

        private

        def merge_row_into_prompt(row)
          merged_prompt = @prompt.dup

          # Replace placeholders (e.g., [content], [file]) with actual values from the row
          row.each do |key, value|
            placeholder = "[#{key}]"
            next unless merged_prompt.include?(placeholder)

            if key == 'content'
              merged_prompt.gsub!(placeholder, value.to_s.gsub('$CR', "\n"))
            else
              merged_prompt.gsub!(placeholder, value.to_s)
            end
          end

          # puts '*' * 80
          # puts merged_prompt
          # puts '*' * 80

          merged_prompt
        end
      end
    end
  end
end
