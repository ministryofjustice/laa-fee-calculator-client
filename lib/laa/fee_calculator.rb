require 'laa/fee_calculator/version'
require 'laa/fee_calculator/configuration'
require 'laa/fee_calculator/connection'
require 'laa/fee_calculator/client'

module LAA
  module FeeCalculator
    USER_AGENT = "LAA-FeeCalculator/#{VERSION}"

    class << self
      def client
        Client.new
      end

      attr_writer :configuration
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def reset
        @configuration = Configuration.new
      end
    end
  end
end
