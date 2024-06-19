# frozen_string_literal: true

module Openai101
  module Models
    # Parameters for the OpenAI API
    class CompletionParams < Openai101::Types::BaseModel
      # attribute :platform, :string, default: 'openai'
      attribute :model, :string
      attribute :prompt, :string
      attribute :temperature, :float, default: 1.0
      attribute :max_tokens, :integer, default: 256
      attribute :top_p, :float, default: 1.0
      attribute :best_of, :integer, default: 1
      attribute :frequency_penalty, :float, default: 0.0
      attribute :presence_penalty, :float, default: 0.0
    end
  end
end
