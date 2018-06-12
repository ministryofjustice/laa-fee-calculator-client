module LAA
  module FeeCalculator
    class Configuration
      DEV_LAA_FEE_CALCULATOR_API_V1 = 'https://laa-fee-calculator-dev.apps.non-production.k8s.integration.dsd.io/api/v1'.freeze
      HEADERS = { 'Accept' => 'application/json' }.freeze

      attr_accessor :host, :headers

      def initialize
        @host ||= host || DEV_LAA_FEE_CALCULATOR_API_V1
        @headers ||= headers || HEADERS
      end
    end
  end
end
