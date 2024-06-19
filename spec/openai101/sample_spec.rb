# frozen_string_literal: true

RSpec.describe Openai101::Sample do
  it 'says hello' do
    expect(described_class.hello).to eq('Hello, World!')
  end
end
