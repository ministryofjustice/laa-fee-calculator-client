require 'laa/fee_calculator/has_many_result'
require "addressable/uri"
class Hash
  # Returns a hash that includes everything but the given keys.
  #   hash = { a: true, b: false, c: nil}
  #   hash.except(:c) # => { a: true, b: false}
  #   hash # => { a: true, b: false, c: nil}
  #
  # This is useful for limiting a set of parameters to everything but a few known toggles:
  #   @person.update(params[:person].except(:admin))
  def except(*keys)
    dup.except!(*keys)
  end

  # Replaces the hash without the given keys.
  #   hash = { a: true, b: false, c: nil}
  #   hash.except!(:c) # => { a: true, b: false}
  #   hash # => { a: true, b: false }
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

module LAA
  module FeeCalculator
    class Client
      include HasManyResult
      extend Forwardable

      attr_reader :connection
      alias conn connection

      attr_accessor :fee_scheme

      def_delegators :connection, :host, :url_prefix, :port, :get, :ping

      has_many_results :advocate_types

      def initialize
        @connection = Connection.instance
      end

      def fee_schemes(id = nil, **options)
        uri = 'fee-schemes/'
        id = id || options.fetch(:id, nil)

        uri.concat("#{id.to_s}/") if id
        uri = Addressable::URI.parse(uri)
        uri.query_values = options.except(:id)
        json = get(uri).body

        ostruct = JSON.parse(json, object_class: OpenStruct)
        return ostruct unless ostruct.respond_to?(:results)
        return ostruct.results.first if ostruct.results.size.eql?(1)
        ostruct.results
      rescue Faraday::ClientError => err
        # TODO: logging
        puts err
      end
    end
  end
end
