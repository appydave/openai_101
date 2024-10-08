# frozen_string_literal: true

GitDiffParser = Openai101::Usecases::GitDiffPipeline::GitDiffParser
DiffProcessor = Openai101::Usecases::GitDiffPipeline::DiffProcessor
PromptMatcher = Openai101::Usecases::GitDiffPipeline::PromptMatcher
MatchProcessor = Openai101::Usecases::GitDiffPipeline::MatchProcessor
DiffReport = Openai101::Usecases::GitDiffPipeline::DiffReport
PromptBuilder = Openai101::Usecases::GitDiffPipeline::PromptBuilder

RSpec.describe 'Full Diff Processing Pipeline', :tools_enabled do
  context 'run the following tools' do
    let(:raw_diff_file) { '/Users/davidcruwys/dev/printspeak/printspeak-master/a1.txt' }
    let(:location) { '/Users/davidcruwys/dev/kgems/openai_101/spec/openai101/usecases/split_diff' }
    let(:raw_diff_content) { File.read(raw_diff_file) }
    let(:processed_diff_file) { "#{location}/diff.json" }
    let(:diff_csv_file) { "#{location}/diff.csv" }
    let(:diff_data) { CSV.read(diff_csv_file, headers: true).map(&:to_h) }
    let(:filtered_items) do
      diff_data.select { |row| row['has_been_processed'] == 'true' && row['match_type'].split.include?('HASH_SHORTHAND_SYNTAX') }
    end
    let(:prompts_folder) { "#{location}/prompts" }

    let(:report_file_path) { "#{location}/report.txt" }
    let(:prompt_path) { "#{location}/prompts" }

    it 'processes and parses diffs into structured JSON format' do
      # Step 1: Use GitDiffParser to extract diffs
      processor = GitDiffParser.new
      diff_result = processor.split_diff(raw_diff_content)

      # Check that the diff extraction is successful
      expect(diff_result).not_to be_empty
      puts 'Step 1: GitDiffParser completed.'

      # Step 2: Use DiffProcessor to structure the diffs into JSON format
      parser = DiffProcessor.new
      parser.parse(diff_result, file: processed_diff_file) # Save the re
      parser.to_csv(diff_csv_file)

      # Check that the JSON structure is correctly built
      expect(parser.json_structure).to be_an(Array)
      expect(parser.json_structure).not_to be_empty
      puts 'Step 2: DiffProcerssor completed.'

      # Final assertions: Verify the content saved to the file is valid and structured as expected
      saved_content = JSON.parse(File.read(processed_diff_file))
      expect(saved_content).to be_an(Array)
      expect(saved_content.first).to include('file', 'has_been_processed', 'diffs')
      puts 'JSON structure successfully saved to file.'
    end

    fit 'loads CSV and processes only one unprocessed entry' do
      # Step 1: Load the CSV file
      match_processor = MatchProcessor.new(csv_file_path: diff_csv_file)

      # Step 2: Define the real prompt and expected values
      prompt = <<-PROMPT
        Analyze the following diff and identify the pattern below:

        Identify instances in this Ruby file where a variable is used twice in a key-value pair (e.g., activity: activity)
        and has been refactored to use shorthand syntax (e.g., activity:).
        Return HASH_SHORTHAND_SYNTAX if this pattern exists.

        If pattern is not found, return NO_MATCH.

        Do not return any other information. Only return HASH_SHORTHAND_SYNTAX or NO_MATCH.

        File content:
        [content]
      PROMPT

      expected_values = %w[HASH_SHORTHAND_SYNTAX]
      default_value = 'NO_MATCH'

      prompt_matcher = PromptMatcher.new(
        prompt: prompt,
        expected_values: expected_values,
        default_value: default_value
      )

      match_processor.process(limit: 1500, progressive_save: true) { |row| prompt_matcher.call(row) }

      processed_entries = match_processor.data.select { |row| row['has_been_processed'] == 'true' }

      # match_processor.save_csv(diff_csv_file)

      puts "#{processed_entries.count} or #{match_processor.data.count} entries processed."
      puts "CSV file updated: #{diff_csv_file}"
    end

    it 'generates a report with matching and non-matching diffs' do
      # diff_content = JSON.parse(File.read(diff_data))
      report = DiffReport.new(diff_data)
      report.print_report

      # Saving the report
      report.save_report("#{location}/report.txt")

      # Validate that the report was saved successfully
      # expect(File.exist?(report_file_path)).to be true
      # expect(File.read(report_file_path)).to include('| File | Processed | Matching Diffs | Non-Matching Diffs |')
      puts 'Report generated and saved successfully.'
    end

    it 'generates prompt files based on pre-filtered items' do
      prompt_builder = PromptBuilder.new

      # Step 1: Define the prompt struct with header, item, and footer
      prompt = PromptBuilder::PromptStruct.new(
        <<~HEADER, # Header part of the prompt
          In this process, we are reversing Ruby's shorthand hash syntax back to its explicit form.
          Below are the specific diffs for each file. Apply the necessary fixes as outlined.
          In this process, we are reversing Rubys shorthand hash syntax (e.g., `activity:`) back to its explicit form (e.g., `activity: activity`).

          For example:
          Before (shorthand): `activity:`
          After (explicit): `activity: activity`

          Similarly, if there are multiple key-value pairs:

          Before (shorthand): `first_name:, last_name:, date_of_birth:`
          After (explicit): `first_name: first_name, last_name: last_name, date_of_birth: date_of_birth`

          Below are the specific diffs for each file. Apply the necessary fixes as outlined.

        HEADER
        <<~ITEM, # Item part of the prompt
          Apply the fix to this code:
          [content]
        ITEM
        <<~FOOTER  # Footer part of the prompt
          Once you've completed the changes, ensure all modified code follows the style guide and is tested.
        FOOTER
      )

      # Step 2: Generate the prompt files based on the filtered items
      prompt_builder.generate_prompts(
        output_dir: prompts_folder,
        items: filtered_items,
        batch_size: 100,
        file_prefix: 'prompt-',
        extension: 'txt',
        prompt: prompt,
        clear_output: true
      )

      # Verify files were created
      generated_files = Dir.glob(File.join(prompts_folder, 'prompt-*.txt'))
      expect(generated_files).not_to be_empty

      puts 'Prompt generation completed.'
    end
  end

  # Step 5: Generate the prompt files with PromptBuilder
  xit 'generates prompt files from the filtered diffs' do
    prompt_builder = PromptBuilder.new
    prompt_builder.generate_prompt_files(processed_diff_file, prompts_folder, batch_size: batch_size)

    generated_files = Dir.glob(File.join(prompts_folder, 'split-prompt-*.txt'))
    expect(generated_files).not_to be_empty

    # Check content of one file to ensure correct generation
    first_file_content = File.read(generated_files.first)
    expect(first_file_content).to include('In this process, we are reversing Rubys shorthand hash syntax')
    puts 'Step 5: PromptBuilder completed.'
  end

  describe PromptMatcher do
    let(:prompt) do
      <<-PROMPT
        Analyze the following diff from the file [file].

        Diff index: [diff_index]
        Content:
        [content]

        Return GORICKY if the pattern is found, otherwise return XMEN.
      PROMPT
    end

    let(:expected_values) { %w[GORICKY XMEN] }
    let(:default_value) { 'XMEN' }

    # Initialize the matcher
    let(:matcher) { PromptMatcher.new(prompt: prompt, expected_values: expected_values, default_value: default_value) }

    # Sample row to process
    let(:row) do
      {
        'file' => 'app/controllers/activities_controller.rb',
        'content' => '--- a/app/controllers/activities_controller.rb\n+++ b/app/controllers/activities_controller.rb\n...',
        'diff_index' => '1',
        'matches' => ''
      }
    end

    context 'when the pattern is found (GORICKY)' do
      before do
        # Mock the behavior of the API response
        allow(OpenAI::Client).to receive_message_chain(:new, :chat).and_return({
                                                                                 'choices' => [{ 'message' => { 'content' => 'GORICKY' } }]
                                                                               })
      end

      it 'returns true and updates the row with the match' do
        result = matcher.call(row)

        expect(result).to be true
        expect(row['matches']).to eq('GORICKY')
      end
    end

    context 'when the pattern is not found then default value is returned (XMEN)' do
      before do
        # Mock the behavior of the API response
        allow(OpenAI::Client).to receive_message_chain(:new, :chat).and_return({
                                                                                 'choices' => [{ 'message' => { 'content' => 'THIS IS SOME ODD VALUE' } }]
                                                                               })
      end

      it 'returns true and updates the row with the match' do
        result = matcher.call(row)

        expect(result).to be false
        expect(row['matches']).to eq('XMEN')
      end
    end

    context 'dynamic prompt placeholder replacement' do
      it 'replaces placeholders with row values in the prompt' do
        filled_prompt = matcher.send(:merge_row_into_prompt, row)

        expect(filled_prompt).to include('app/controllers/activities_controller.rb')
        expect(filled_prompt).to include('Diff index: 1')
      end
    end
  end
end
