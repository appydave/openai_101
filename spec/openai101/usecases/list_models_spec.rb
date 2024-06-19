# frozen_string_literal: true

RSpec.describe 'List Models', :tools_enabled do
  let(:client) { OpenAI::Client.new }

  it 'list models' do
    models = client.models.list['data'].reject { |model| model['owned_by'] == 'print-speak' }
    tp models
  end
end
