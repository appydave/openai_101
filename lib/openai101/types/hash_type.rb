# frozen_string_literal: true

module Openai101
  module Types
    # Used by the ActiveModel attributes API to cast values to hashes
    class HashType < ActiveModel::Type::Value
      def cast(value)
        case value
        when String
          JSON.parse(value)
        when Hash
          value
        else
          raise ArgumentError, "Cannot cast #{value.class} to Hash"
        end
      end

      def serialize(value)
        value.to_json
      end
    end
  end
end

ActiveModel::Type.register(:hash, Openai101::Types::HashType)
