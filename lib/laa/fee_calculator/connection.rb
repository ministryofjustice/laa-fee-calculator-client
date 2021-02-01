# frozen_string_literal: true

require 'singleton'
require 'faraday'

module LAA
  module FeeCalculator
    class Connection
      include Singleton
      extend Forwardable

      attr_reader :conn

      def_delegators :conn, :port, :headers, :url_prefix, :options, :ssl, :get

      def initialize
        @conn = Faraday.new(url: LAA::FeeCalculator.configuration.host, headers: default_headers) do |conn|
          conn.use LAA::FeeCalculator::RaiseError
          conn.adapter :net_http
        end
      end

      class << self
        def host
          LAA::FeeCalculator.configuration.host
        end
      end

      def host
        self.class.host
      end

      def ping
        get('/ping.json')
      end

      private

      def default_headers
        LAA::FeeCalculator.configuration.headers
      end
    end
  end
end
