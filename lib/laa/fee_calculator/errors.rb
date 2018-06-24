# frozen_string_literal: true

module LAA
  module FeeCalculator
    # base error class
    class ClientError < StandardError
    end

    # response error
    # - handle empty results ie. results: []
    # - handle error message response - 400, ["`case_date` should be in the format YYYY-MM-DD"]
    # - handle everything else by passing the status and message along
    # raised for failed response status between 300 and 599
    class ResponseError < ClientError
      attr_reader :status, :headers, :body

      # check body of response as the status
      # may provide details of error
      def initialize(response)
        @status = response.fetch(:status, nil)
        @headers = response.fetch(:headers, nil)
        @body = response.fetch(:body, nil)
      end

      # overide the e.message attribute
      # e.g. raise LAA::FeeCalculator::ResponseError.new(response)
      # => #<LAA::FeeCalculator::ResponseError: "`case_date` should be in the format YYYY-MM-DD">
      def to_s
        body
      end
    end

    # raised when:
    # - empty results i.e. results: [] ??
    # - API returns detail not found errors - 404, { "detail": "Not found." }
    class ResourceNotFound < ResponseError
      def to_s
        h = JSON.parse(body)
        h.each_with_object(+'') do |(k, v), message|
          message.concat("#{k} #{v}")
        end
      end
    end

    # TODO: request error??
    # could raise for invalid params
  end
end
