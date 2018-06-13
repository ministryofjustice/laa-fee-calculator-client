require 'json'

# TODO: possibly override Enumerable `find` to emulate AR
# e.g. client.fee_schemes.find(1), client.fee_schemes.find(supplier_type: 'SOLICITOR')
#
# class OpenStructResult < OpenStruct
#   alias :enum_find :find

#   def find(id, options = {})
#     enum_find do |el|
#       return el if el.id.eql? unless options
#       options.all? { |key, value| el.send(key).eql?(value) } if options
#     end
#   end
# end

# TODO: would be good if it worked like this
# client.fee_scheme = 1
# client.fee_schemes(1).advocate_types(1)

module LAA
  module FeeCalculator
    module HasManyResult
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def has_many_results(association)

          define_method("#{association}_uri".to_sym) do |scheme_pk=nil|
            scheme_pk.nil? ? "#{association.to_s.gsub('_','-')}/" : "fee-schemes/#{scheme_pk}/#{association.to_s.gsub('_','-')}/"
          end

          define_method(association) do
            # scheme_pk = scheme_pk || options&.fetch(:scheme_pk, nil) || self.fee_scheme
            uri = self.send("#{association}_uri", self.id)
            uri = Addressable::URI.parse(uri)
            json = get(uri).body
            ostruct = JSON.parse(json, object_class: OpenStruct)
            ostruct.results
          end

          # def advocate_types
          #   uri = Addressable::URI.parse("fee-schemes/#{self.id}/advocate-types/")
          #   json = get(uri).body
          #   ostruct = JSON.parse(json, object_class: OpenStruct)
          #   ostruct.results
          # end
        end
      end
    end
  end
end
