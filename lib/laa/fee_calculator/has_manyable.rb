require 'json'
module LAA
  module FeeCalculator
    module HasManyable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def has_many(association)

          define_method("#{association}_uri".to_sym) do |scheme_pk = nil, id = nil|
            uri = scheme_pk.nil? ? "#{association.to_s.gsub('_','-')}/" : "fee-schemes/#{scheme_pk}/#{association.to_s.gsub('_','-')}/"
            uri = uri.concat("#{id.to_s}/") unless id.nil?
            Addressable::URI.parse(uri)
          end

          define_method(association) do |id = nil, **options|
            id = id || options&.fetch(:id, nil)
            uri = self.send("#{association}_uri", self.id, id)
            uri.query_values = options.except(:id)

            json = get(uri).body
            ostruct = JSON.parse(json, object_class: OpenStruct)

            return ostruct unless ostruct.respond_to?(:results)
            return ostruct.results.first if ostruct.results.size.eql?(1)
            ostruct.results
          rescue Faraday::ResourceNotFound => err
            # TODO: logging
          end
        end
      end
    end
  end
end
