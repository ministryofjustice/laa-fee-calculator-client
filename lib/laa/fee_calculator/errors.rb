# frozen_string_literal: true

module LAA
  module FeeCalculator
    # see: laa/fee_calculator/raise_error

    # raised for failed response status between 400 and 599 and not handled
    # by classes below
    class ClientError < Faraday::Error::ClientError
      # overide the e.message attribute
      # e.g. raise LAA::FeeCalculator::ResponseError.new(response)
      # => #<LAA::FeeCalculator::ResponseError: "`case_date` should be in the format YYYY-MM-DD">
      def to_s
        response[:body]
      end
    end

    # raised when API response is bad request: 400
    # e.g. body ["`case_date` should be in the format YYYY-MM-DD"]
    class ResponseError < ClientError
    end

    # raised when API response is not found: 404:
    # e.g. body { "detail": "Not found." }
    # TODO: consider raising for empty results i.e. results: [] ??
    class ResourceNotFound < ResponseError
      def to_s
        h = JSON.parse(response[:body])
        h.each_with_object(+'') do |(k, v), message|
          message.concat("#{k} #{v}")
        end
      end
    end
  end
end
