# frozen_string_literal: true

RSpec.describe 'Simple Prompt', :tools_enabled do
  let(:client) { OpenAI::Client.new }

  it 'makes a simple prompt call' do
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: 'How are you?' }],
        temperature: 0.7
      }
    )

    puts response.dig('choices', 0, 'message', 'content')
    expect(response.dig('choices', 0, 'message', 'content')).not_to be_empty
  end
end
