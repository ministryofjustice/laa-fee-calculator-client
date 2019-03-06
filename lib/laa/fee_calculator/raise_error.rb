# frozen_string_literal: true

require 'faraday'
require 'laa/fee_calculator/errors'

module LAA
  module FeeCalculator
    # Wrap Faraday adapter error handling with
    # gem specific handlers.
    #
    class RaiseError < Faraday::Response::Middleware
      CLIENT_ERROR_STATUSES = (400...600).freeze

      def on_complete(env)
        case env[:status]
        when 400
          raise LAA::FeeCalculator::ResponseError.new(response_values(env))
        when 404
          raise LAA::FeeCalculator::ResourceNotFound.new(response_values(env))
        when CLIENT_ERROR_STATUSES
          raise LAA::FeeCalculator::ClientError.new(response_values(env))
        end
      end

      def response_values(env)
        { status: env.status, headers: env.response_headers, body: env.body }
      end
    end
  end
end
