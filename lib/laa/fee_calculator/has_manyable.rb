# frozen_string_literal: true

require 'json'

module LAA
  module FeeCalculator
    module HasManyable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        module Searchable
          def find_by(**options)
            find do |ostruct|
              options.map { |k, v| ostruct[k].eql?(v) }.all?
            end
          end
        end

        def has_many(association)
          define_method(association) do |id = nil, **options|
            uri = uri_for(association, id: id || options[:id])
            filtered_params = options.except(:id)

            json = get(uri, filtered_params).body

            ostruct = JSON.parse(json, object_class: OpenStruct)
            return ostruct unless ostruct.respond_to?(:results)

            ostruct.results.extend Searchable
          end
        end
      end

      def uri_for(association, id: nil)
        return "#{base_fee_scheme_uri}#{association.to_s.tr('_', '-')}/" if id.nil?

        "#{base_fee_scheme_uri}#{association.to_s.tr('_', '-')}/#{id}/"
      end

      def base_fee_scheme_uri
        id ? "fee-schemes/#{id}/" : ''
      end
    end
  end
end
