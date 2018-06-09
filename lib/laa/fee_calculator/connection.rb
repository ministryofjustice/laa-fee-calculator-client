require 'singleton'

module LAA
  module FeeCalculator
  	class Connection

      include Singleton

      class << self
        def host
          LAA::FeeCalculator.configuration.host
        end
      end

      def host
        self.class.host
      end

      def ping
        # self.get('/')
      end
  	end	 
  end
end
