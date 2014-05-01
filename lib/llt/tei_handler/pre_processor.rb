module LLT
  module TeiHandler
    class PreProcessor
      require 'nokogiri'

      def initialize(document)
        @document = Nokogiri::XML(document)
        raise ArgumentError.new('Document is no TEI XML') unless is_tei?
      end

      def is_tei?
        @document.root.name == 'TEI'
      end
    end
  end
end
