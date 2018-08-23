# frozen_string_literal: true

module LAA
  module FeeCalculator
    class Configuration
      LAA_FEE_CALCULATOR_API_V1 = 'https://laa-fee-calculator-production.apps.cloud-platform-live-0.k8s.integration.dsd.io/api/v1'
      HEADERS = { 'Accept' => 'application/json', 'User-Agent' => USER_AGENT }.freeze

      attr_accessor :host, :headers

      def initialize
        @host ||= host || LAA_FEE_CALCULATOR_API_V1
        @headers ||= headers || HEADERS
      end
    end
  end
end
