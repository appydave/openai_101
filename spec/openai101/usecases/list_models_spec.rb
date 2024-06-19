# frozen_string_literal: true

RSpec.describe 'List Models', :tools_enabled do
  let(:client) { OpenAI::Client.new }

  it 'list models' do
    models = client.models.list['data']
                   .reject { |model| model['owned_by'] == 'print-speak' }
                   .sort_by { |model| -model['created'] }
    tp models
  end

  it 'retrieve a model' do
    model = client.models.retrieve(id: 'gpt-4o-2024-05-13')

    tp [model]
  end
end
