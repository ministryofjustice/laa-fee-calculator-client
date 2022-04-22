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
          define_method("#{association}_uri".to_sym) do |scheme_pk = nil, id = nil|
            uri = if scheme_pk.nil?
                    "#{association.to_s.tr('_', '-')}/"
                  else
                    "fee-schemes/#{scheme_pk}/#{association.to_s.tr('_', '-')}/"
                  end
            uri = uri.concat(id.to_s, '/') unless id.nil?
            Addressable::URI.parse(uri)
          end

          define_method(association) do |id = nil, **options|
            id ||= options&.fetch(:id, nil)
            uri = self.send("#{association}_uri", self.id, id)
            uri.query_values = options.reject { |k, _v| k.eql?(:id) }

            json = get(uri).body

            ostruct = JSON.parse(json, object_class: OpenStruct)
            return ostruct unless ostruct.respond_to?(:results)

            ostruct.results.extend Searchable
          end
        end
      end
    end
  end
end
