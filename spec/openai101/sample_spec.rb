# frozen_string_literal: true

RSpec.describe Openai101::Sample, :tools_enabled do
  it 'says hello' do
    expect(described_class.hello).to eq('Hello, World!')
  end
end
