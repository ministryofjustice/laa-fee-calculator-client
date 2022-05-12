# frozen_string_literal: true

module LAA
  module FeeCalculator
    module BaseField
      def self.included(base)
        attr_accessor(*base::ATTRIBUTES)

        base.extend ClassMethods
      end

      module ClassMethods
        def find(id, base_uri: '')
          new(**JSON.parse(Connection.instance.get("#{base_uri}prices/#{id}/").body))
        end
      end

      def initialize(**kwargs)
        self.class::ATTRIBUTES.each do |attr|
          send("#{attr}=", kwargs[attr.to_s])
        end
      end

      def [](key)
        return unless self.class::ATTRIBUTES.include?(key.to_sym)

        send(key.to_sym)
      end
    end
  end
end
