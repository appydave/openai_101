# frozen_string_literal: true

RSpec.describe Openai101::Models::CompletionParams do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      model: 'gpt-4',
      prompt: 'What is the capital of France?',
      temperature: 0.7,
      max_tokens: 128,
      top_p: 0.9,
      frequency_penalty: 0.5,
      presence_penalty: 0.5
    }
  end

  it 'has default values for temperature, max_tokens, top_p, frequency_penalty, and presence_penalty' do
    params = described_class.new
    expect(params.temperature).to eq(1.0)
    expect(params.max_tokens).to eq(256)
    expect(params.top_p).to eq(1.0)
    expect(params.frequency_penalty).to eq(0.0)
    expect(params.presence_penalty).to eq(0.0)
  end

  it 'assigns attributes correctly' do
    expect(subject.model).to eq('gpt-4')
    expect(subject.prompt).to eq('What is the capital of France?')
    expect(subject.temperature).to eq(0.7)
    expect(subject.max_tokens).to eq(128)
    expect(subject.top_p).to eq(0.9)
    expect(subject.frequency_penalty).to eq(0.5)
    expect(subject.presence_penalty).to eq(0.5)
  end

  context 'when some attributes are not provided' do
    let(:attributes) do
      {
        model: 'gpt-4',
        prompt: 'What is the capital of France?'
      }
    end

    it 'uses default values for missing attributes' do
      expect(subject.model).to eq('gpt-4')
      expect(subject.prompt).to eq('What is the capital of France?')
      expect(subject.temperature).to eq(1.0)
      expect(subject.max_tokens).to eq(256)
      expect(subject.top_p).to eq(1.0)
      expect(subject.frequency_penalty).to eq(0.0)
      expect(subject.presence_penalty).to eq(0.0)
    end
  end
end
